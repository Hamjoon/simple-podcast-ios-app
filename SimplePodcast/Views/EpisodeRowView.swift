import SwiftUI

/// A single episode row in the episodes list
struct EpisodeRowView: View {
    @EnvironmentObject var viewModel: PodcastViewModel
    let episode: Episode

    private var isCurrentEpisode: Bool {
        viewModel.isCurrentEpisode(episode)
    }

    /// Returns description if available, otherwise extracts text after first colon from title
    private var displayDescription: String {
        let trimmedDescription = episode.description.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedDescription.isEmpty {
            return episode.description
        }
        // Extract text after first colon, or use entire title if no colon
        if let colonIndex = episode.title.firstIndex(of: ":") {
            let afterColon = episode.title[episode.title.index(after: colonIndex)...]
            return String(afterColon).trimmingCharacters(in: .whitespaces)
        }
        return episode.title
    }

    var body: some View {
        HStack(spacing: 15) {
            // Episode thumbnail with publish date below
            VStack(spacing: 6) {
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
                .frame(width: 70, height: 70)
                .cornerRadius(8)
                .clipped()

                // Publish Date
                Text(episode.formattedPubDate)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isCurrentEpisode ? .white.opacity(0.9) : Color.gray)
            }

            // Episode details
            VStack(alignment: .leading, spacing: 5) {
                Text(episode.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isCurrentEpisode ? .white : .primary)
                    .lineLimit(2)

                Text(displayDescription)
                    .font(.system(size: 13))
                    .foregroundColor(isCurrentEpisode ? .white.opacity(0.9) : .secondary)
                    .lineLimit(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
            duration: "45:30",
            pubDate: "Mon, 25 Nov 2024 10:00:00 +0900"
        ))
    }
    .padding()
    .environmentObject(PodcastViewModel())
}
