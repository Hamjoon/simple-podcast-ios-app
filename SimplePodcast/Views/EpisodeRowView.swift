import SwiftUI

/// A single episode row in the episodes list
struct EpisodeRowView: View {
    @EnvironmentObject var viewModel: PodcastViewModel
    let episode: Episode

    private var isCurrentEpisode: Bool {
        viewModel.isCurrentEpisode(episode)
    }

    var body: some View {
        HStack(spacing: 15) {
            // Episode thumbnail with caching
            CachedAsyncImage(
                url: URL(string: episode.imageUrl),
                content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                },
                placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay {
                            Image(systemName: "music.note")
                                .foregroundColor(.gray)
                        }
                }
            )
            .frame(width: 80, height: 80)
            .cornerRadius(8)
            .clipped()

            // Episode details
            VStack(alignment: .leading, spacing: 5) {
                Text(episode.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isCurrentEpisode ? .white : .primary)
                    .lineLimit(1)

                Text(episode.description)
                    .font(.system(size: 13))
                    .foregroundColor(isCurrentEpisode ? .white.opacity(0.9) : .secondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Duration
            Text(episode.duration)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isCurrentEpisode ? .white.opacity(0.9) : Color.gray)
        }
        .padding(15)
        .background(
            isCurrentEpisode
                ? Color.activeEpisode
                : Color(UIColor.systemGray6)
        )
        .cornerRadius(10)
        .animation(.easeInOut(duration: 0.2), value: isCurrentEpisode)
    }
}

#Preview {
    VStack {
        EpisodeRowView(episode: Episode(
            id: 1,
            title: "Sample Episode Title",
            description: "This is a sample episode description that might be quite long.",
            audioUrl: "https://example.com/audio.mp3",
            imageUrl: "https://example.com/image.jpg",
            duration: "45:30"
        ))
    }
    .padding()
    .environmentObject(PodcastViewModel())
}
