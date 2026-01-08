import Foundation

/// A search result associating an episode with its source podcast
struct SearchResult: Identifiable {
    /// Composite ID to ensure uniqueness across podcasts
    let id: String
    let episode: Episode
    let podcast: Podcast

    init(episode: Episode, podcast: Podcast) {
        self.id = "\(podcast.id)-\(episode.id)"
        self.episode = episode
        self.podcast = podcast
    }
}
