import Foundation

/// Service for handling API calls to the podcast backend
actor APIService {
    static let shared = APIService()

    private let baseURL = "https://web-production-65db2.up.railway.app"
    private let decoder: JSONDecoder

    private init() {
        decoder = JSONDecoder()
    }

    /// Fetches episodes for a specific podcast from the API
    /// - Parameter podcastId: The podcast identifier (e.g., "film-club", "taste-of-travel", "seodam")
    /// - Returns: Array of Episode objects
    /// - Throws: APIError if the request fails
    func fetchEpisodes(for podcastId: String) async throws -> [Episode] {
        guard let url = URL(string: "\(baseURL)/api/episodes/\(podcastId)") else {
            throw APIError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        let episodesResponse = try decoder.decode(EpisodesResponse.self, from: data)

        guard episodesResponse.success else {
            throw APIError.serverError(message: episodesResponse.error ?? "Unknown error")
        }

        guard let episodes = episodesResponse.episodes else {
            throw APIError.noData
        }

        return episodes
    }

    /// Fetches all podcast episodes from the API (default: film-club for backwards compatibility)
    /// - Returns: Array of Episode objects
    /// - Throws: APIError if the request fails
    func fetchEpisodes() async throws -> [Episode] {
        return try await fetchEpisodes(for: "film-club")
    }

    /// Fetches episodes from all podcasts concurrently
    /// - Returns: Dictionary mapping podcast ID to episodes array
    /// - Throws: APIError if any request fails
    func fetchAllEpisodes() async throws -> [String: [Episode]] {
        try await withThrowingTaskGroup(of: (String, [Episode]).self) { group in
            for podcast in Podcast.allPodcasts {
                group.addTask {
                    let episodes = try await self.fetchEpisodes(for: podcast.id)
                    return (podcast.id, episodes)
                }
            }

            var results: [String: [Episode]] = [:]
            for try await (podcastId, episodes) in group {
                results[podcastId] = episodes
            }
            return results
        }
    }
}

/// Errors that can occur during API calls
enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case serverError(message: String)
    case noData

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .noData:
            return "No data received"
        }
    }
}
