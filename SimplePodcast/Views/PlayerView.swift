import SwiftUI

/// Player view showing current episode and controls
struct PlayerView: View {
    @EnvironmentObject var viewModel: PodcastViewModel

    var body: some View {
        VStack(spacing: 20) {
            // Now playing section
            NowPlayingSection()

            // Audio controls
            AudioControlsView()

            // Sleep timer
            SleepTimerView()
        }
    }
}

/// Section showing the currently playing episode info
struct NowPlayingSection: View {
    @EnvironmentObject var viewModel: PodcastViewModel

    var body: some View {
        HStack(spacing: 20) {
            // Episode artwork
            AsyncImage(url: URL(string: viewModel.audioPlayer.currentEpisode?.imageUrl ?? "")) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay {
                            ProgressView()
                        }
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay {
                            Image(systemName: "music.note")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 120, height: 120)
            .cornerRadius(10)
            .clipped()

            // Episode info
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.audioPlayer.currentEpisode?.title ?? "Select an episode")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)

                Text(viewModel.audioPlayer.currentEpisode?.description ?? "")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

/// Audio controls with play/pause and progress slider
struct AudioControlsView: View {
    @EnvironmentObject var viewModel: PodcastViewModel

    var body: some View {
        VStack(spacing: 12) {
            // Progress slider
            VStack(spacing: 4) {
                Slider(
                    value: Binding(
                        get: { viewModel.audioPlayer.progress },
                        set: { newValue in
                            let newTime = newValue * viewModel.audioPlayer.duration
                            viewModel.audioPlayer.seek(to: newTime)
                        }
                    ),
                    in: 0...1
                )
                .accentColor(.primaryGradientStart)
                .disabled(viewModel.audioPlayer.currentEpisode == nil)

                // Time labels
                HStack {
                    Text(formatTime(viewModel.audioPlayer.currentTime))
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(formatTime(viewModel.audioPlayer.duration))
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }

            // Playback controls
            HStack(spacing: 40) {
                // Skip backward button
                Button {
                    viewModel.audioPlayer.skipBackward(seconds: 15)
                } label: {
                    Image(systemName: "gobackward.15")
                        .font(.system(size: 28))
                        .foregroundColor(.primary)
                }
                .disabled(viewModel.audioPlayer.currentEpisode == nil)

                // Play/Pause button
                Button {
                    viewModel.audioPlayer.togglePlayPause()
                } label: {
                    Image(systemName: playButtonImageName)
                        .font(.system(size: 48))
                        .foregroundColor(.primaryGradientStart)
                }
                .disabled(viewModel.audioPlayer.currentEpisode == nil)

                // Skip forward button
                Button {
                    viewModel.audioPlayer.skipForward(seconds: 15)
                } label: {
                    Image(systemName: "goforward.15")
                        .font(.system(size: 28))
                        .foregroundColor(.primary)
                }
                .disabled(viewModel.audioPlayer.currentEpisode == nil)
            }
        }
    }

    private var playButtonImageName: String {
        switch viewModel.audioPlayer.playbackState {
        case .playing:
            return "pause.circle.fill"
        case .loading:
            return "circle.dotted"
        default:
            return "play.circle.fill"
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        guard time.isFinite && time >= 0 else { return "0:00" }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    PlayerView()
        .padding()
        .environmentObject(PodcastViewModel())
}
