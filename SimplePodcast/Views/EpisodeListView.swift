import SwiftUI

/// View displaying the list of podcast episodes
struct EpisodeListView: View {
    @EnvironmentObject var viewModel: PodcastViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section header
            Text("Episodes")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)

            Divider()

            // Episodes content
            switch viewModel.loadingState {
            case .idle, .loading:
                LoadingView()

            case .loaded:
                EpisodesContent()

            case .error(let message):
                ErrorView(message: message) {
                    Task {
                        await viewModel.fetchEpisodes()
                    }
                }
            }
        }
    }
}

/// Loading indicator view
struct LoadingView: View {
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 12) {
                ProgressView()
                Text("Loading episodes...")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 40)
            Spacer()
        }
    }
}

/// Error view with retry button
struct ErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.orange)

            Text("Failed to load episodes")
                .font(.system(size: 16, weight: .semibold))

            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button(action: onRetry) {
                Text("Try Again")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color.primaryGradientStart)
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
    }
}

/// List of episodes
struct EpisodesContent: View {
    @EnvironmentObject var viewModel: PodcastViewModel

    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.episodes) { episode in
                EpisodeRowView(episode: episode)
                    .onTapGesture {
                        viewModel.play(episode: episode)
                    }
            }
        }
    }
}

#Preview {
    EpisodeListView()
        .padding()
        .environmentObject(PodcastViewModel())
}
