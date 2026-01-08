import Foundation
import Combine

/// Loading state for the search feature
enum SearchLoadingState: Equatable {
    case idle
    case loading
    case ready
    case error(String)
}

/// ViewModel for the search feature
@MainActor
class SearchViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var searchText: String = ""
    @Published private(set) var searchResults: [SearchResult] = []
    @Published private(set) var loadingState: SearchLoadingState = .idle

    // MARK: - Services

    let audioPlayer: AudioPlayerService

    // MARK: - Private Properties

    private var allEpisodes: [String: [Episode]] = [:]
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init() {
        self.audioPlayer = AudioPlayerService.shared
        setupSearch()
        setupAudioPlayerObservation()
    }

    /// Setup debounced search
    private func setupSearch() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }

    /// Forward AudioPlayerService changes to trigger view updates
    private func setupAudioPlayerObservation() {
        audioPlayer.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Methods

    /// Fetch episodes from all podcasts
    func fetchAllEpisodes() async {
        guard loadingState != .loading else { return }

        loadingState = .loading

        do {
            allEpisodes = try await APIService.shared.fetchAllEpisodes()
            loadingState = .ready
        } catch {
            loadingState = .error(error.localizedDescription)
        }
    }

    /// Play a specific episode
    func play(episode: Episode) {
        audioPlayer.play(episode: episode)
    }

    /// Check if the given episode is the current episode
    func isCurrentEpisode(_ episode: Episode) -> Bool {
        audioPlayer.currentEpisode?.id == episode.id
    }

    // MARK: - Private Methods

    /// Perform search across all episodes
    private func performSearch(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespaces)

        guard !trimmedQuery.isEmpty else {
            searchResults = []
            return
        }

        let lowercasedQuery = trimmedQuery.lowercased()
        var results: [SearchResult] = []

        for podcast in Podcast.allPodcasts {
            guard let episodes = allEpisodes[podcast.id] else { continue }

            let matches = episodes.filter { episode in
                episode.title.lowercased().contains(lowercasedQuery) ||
                episode.description.lowercased().contains(lowercasedQuery)
            }

            results.append(contentsOf: matches.map { SearchResult(episode: $0, podcast: podcast) })
        }

        // Sort by publish date (newest first)
        searchResults = results.sorted { $0.episode.pubDate > $1.episode.pubDate }
    }
}
