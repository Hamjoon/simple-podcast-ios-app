import Foundation
import Combine

/// Loading state for the episodes list
enum LoadingState {
    case idle
    case loading
    case loaded
    case error(String)
}

/// Main ViewModel for the podcast application
@MainActor
class PodcastViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var episodes: [Episode] = []
    @Published private(set) var loadingState: LoadingState = .idle

    // MARK: - Services

    let audioPlayer: AudioPlayerService
    let sleepTimer: SleepTimerManager

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init() {
        self.audioPlayer = AudioPlayerService.shared
        self.sleepTimer = SleepTimerManager.shared

        setupAutoPlayNext()
    }

    // MARK: - Public Methods

    /// Fetch episodes from the API
    func fetchEpisodes() async {
        loadingState = .loading

        do {
            let fetchedEpisodes = try await APIService.shared.fetchEpisodes()
            episodes = fetchedEpisodes
            loadingState = .loaded
        } catch {
            loadingState = .error(error.localizedDescription)
        }
    }

    /// Play a specific episode
    /// - Parameter episode: The episode to play
    func play(episode: Episode) {
        audioPlayer.play(episode: episode)
    }

    /// Check if the given episode is currently playing
    /// - Parameter episode: The episode to check
    /// - Returns: True if the episode is currently playing
    func isPlaying(episode: Episode) -> Bool {
        audioPlayer.currentEpisode?.id == episode.id &&
        audioPlayer.playbackState == .playing
    }

    /// Check if the given episode is the current episode (playing or paused)
    /// - Parameter episode: The episode to check
    /// - Returns: True if the episode is the current episode
    func isCurrentEpisode(_ episode: Episode) -> Bool {
        audioPlayer.currentEpisode?.id == episode.id
    }

    // MARK: - Private Methods

    /// Setup auto-play next episode functionality
    private func setupAutoPlayNext() {
        NotificationCenter.default.publisher(for: .episodeDidFinishPlaying)
            .compactMap { $0.object as? Episode }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] finishedEpisode in
                self?.playNextEpisode(after: finishedEpisode)
            }
            .store(in: &cancellables)
    }

    /// Play the next episode after the current one finishes
    /// - Parameter episode: The episode that just finished
    private func playNextEpisode(after episode: Episode) {
        guard let currentIndex = episodes.firstIndex(where: { $0.id == episode.id }) else {
            return
        }

        let nextIndex = currentIndex + 1
        guard nextIndex < episodes.count else {
            return
        }

        let nextEpisode = episodes[nextIndex]
        play(episode: nextEpisode)
    }
}
