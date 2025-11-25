import AVFoundation
import MediaPlayer
import Combine

/// Represents the current playback state
enum PlaybackState {
    case stopped
    case playing
    case paused
    case loading
}

/// Service for managing audio playback using AVPlayer
@MainActor
class AudioPlayerService: ObservableObject {
    static let shared = AudioPlayerService()

    // MARK: - Published Properties

    @Published private(set) var playbackState: PlaybackState = .stopped
    @Published private(set) var currentEpisode: Episode?
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published private(set) var progress: Double = 0

    // MARK: - Private Properties

    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    private init() {
        setupAudioSession()
        setupRemoteCommandCenter()
    }

    // MARK: - Audio Session Setup

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    // MARK: - Remote Command Center Setup

    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.resume()
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }

        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.togglePlayPause()
            return .success
        }

        commandCenter.skipForwardCommand.preferredIntervals = [15]
        commandCenter.skipForwardCommand.addTarget { [weak self] _ in
            self?.skipForward(seconds: 15)
            return .success
        }

        commandCenter.skipBackwardCommand.preferredIntervals = [15]
        commandCenter.skipBackwardCommand.addTarget { [weak self] _ in
            self?.skipBackward(seconds: 15)
            return .success
        }

        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            self?.seek(to: event.positionTime)
            return .success
        }
    }

    // MARK: - Playback Controls

    /// Play a specific episode
    /// - Parameter episode: The episode to play
    func play(episode: Episode) {
        guard let url = URL(string: episode.audioUrl) else {
            print("Invalid audio URL: \(episode.audioUrl)")
            return
        }

        // Stop current playback
        stop()

        currentEpisode = episode
        playbackState = .loading

        // Create player item and player
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)

        // Observe player item status
        observePlayerItem()

        // Start playing
        player?.play()
        playbackState = .playing

        // Setup time observer
        setupTimeObserver()

        // Update now playing info
        updateNowPlayingInfo()
    }

    /// Pause playback
    func pause() {
        player?.pause()
        playbackState = .paused
        updateNowPlayingInfo()
    }

    /// Resume playback
    func resume() {
        player?.play()
        playbackState = .playing
        updateNowPlayingInfo()
    }

    /// Toggle between play and pause
    func togglePlayPause() {
        switch playbackState {
        case .playing:
            pause()
        case .paused:
            resume()
        case .stopped:
            if let episode = currentEpisode {
                play(episode: episode)
            }
        case .loading:
            break
        }
    }

    /// Stop playback completely
    func stop() {
        removeTimeObserver()
        player?.pause()
        player = nil
        playerItem = nil
        playbackState = .stopped
        currentTime = 0
        duration = 0
        progress = 0
        clearNowPlayingInfo()
    }

    /// Skip forward by specified seconds
    /// - Parameter seconds: Number of seconds to skip forward
    func skipForward(seconds: Double) {
        guard player != nil else { return }
        let newTime = currentTime + seconds
        let clampedTime = min(newTime, duration)
        seek(to: clampedTime)
    }

    /// Skip backward by specified seconds
    /// - Parameter seconds: Number of seconds to skip backward
    func skipBackward(seconds: Double) {
        guard player != nil else { return }
        let newTime = max(0, currentTime - seconds)
        seek(to: newTime)
    }

    /// Seek to a specific time
    /// - Parameter time: Time in seconds to seek to
    func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime) { [weak self] _ in
            Task { @MainActor in
                self?.updateNowPlayingInfo()
            }
        }
    }

    // MARK: - Private Methods

    private func observePlayerItem() {
        guard let playerItem = playerItem else { return }

        // Observe when playback ends
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            .sink { [weak self] _ in
                self?.handlePlaybackEnded()
            }
            .store(in: &cancellables)

        // Observe duration
        playerItem.publisher(for: \.duration)
            .compactMap { duration -> TimeInterval? in
                guard duration.isNumeric else { return nil }
                return duration.seconds
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] duration in
                self?.duration = duration
            }
            .store(in: &cancellables)
    }

    private func setupTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            let seconds = time.seconds
            Task { @MainActor in
                guard let self = self else { return }
                self.currentTime = seconds
                if self.duration > 0 {
                    self.progress = self.currentTime / self.duration
                }
            }
        }
    }

    private func removeTimeObserver() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        cancellables.removeAll()
    }

    private func handlePlaybackEnded() {
        playbackState = .stopped
        currentTime = 0
        progress = 0

        // Post notification for auto-play next episode
        NotificationCenter.default.post(name: .episodeDidFinishPlaying, object: currentEpisode)
    }

    // MARK: - Now Playing Info

    private func updateNowPlayingInfo() {
        guard let episode = currentEpisode else { return }

        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = episode.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = "Simple Podcast"
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = playbackState == .playing ? 1.0 : 0.0

        // Load artwork asynchronously
        if let imageURL = URL(string: episode.imageUrl) {
            Task {
                if let (data, _) = try? await URLSession.shared.data(from: imageURL),
                   let image = UIImage(data: data) {
                    let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                    nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                }
            }
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    private func clearNowPlayingInfo() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let episodeDidFinishPlaying = Notification.Name("episodeDidFinishPlaying")
}
