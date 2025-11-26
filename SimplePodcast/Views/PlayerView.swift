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
            Group {
                if let imageUrl = viewModel.audioPlayer.currentEpisode?.imageUrl,
                   let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
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
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay {
                            Image(systemName: "music.note")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        }
                }
            }
            .frame(width: 120, height: 120)
            .cornerRadius(10)
            .clipped()

            // Episode info
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.audioPlayer.currentEpisode?.title ?? String(localized: "Select an episode"))
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
    @State private var isDragging = false
    @State private var dragValue: Double = 0

    var body: some View {
        VStack(spacing: 12) {
            // Progress slider
            VStack(spacing: 4) {
                Slider(
                    value: Binding(
                        get: { isDragging ? dragValue : viewModel.audioPlayer.progress },
                        set: { newValue in
                            dragValue = newValue
                        }
                    ),
                    in: 0...1,
                    onEditingChanged: { editing in
                        if editing {
                            isDragging = true
                        } else {
                            // Seek only when drag ends
                            let newTime = dragValue * viewModel.audioPlayer.duration
                            viewModel.audioPlayer.seek(to: newTime)
                            // Delay switching back to progress to avoid visual jump
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isDragging = false
                            }
                        }
                    }
                )
                .accentColor(.primaryGradientStart)
                .disabled(viewModel.audioPlayer.currentEpisode == nil)

                // Time labels
                HStack {
                    Text(formatTime(isDragging ? dragValue * viewModel.audioPlayer.duration : viewModel.audioPlayer.currentTime))
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
