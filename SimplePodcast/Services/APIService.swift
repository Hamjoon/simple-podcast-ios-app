import Foundation

/// Service for handling API calls to the podcast backend
actor APIService {
    static let shared = APIService()

    private let baseURL = "https://simple-podcast-production.up.railway.app"
    private let decoder: JSONDecoder

    private init() {
        decoder = JSONDecoder()
    }

    /// Fetches all podcast episodes from the API
    /// - Returns: Array of Episode objects
    /// - Throws: APIError if the request fails
    func fetchEpisodes() async throws -> [Episode] {
        guard let url = URL(string: "\(baseURL)/api/episodes") else {
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
