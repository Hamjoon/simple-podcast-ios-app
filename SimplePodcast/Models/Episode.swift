import Foundation

/// Represents a single podcast episode
struct Episode: Identifiable, Codable, Equatable {
    let id: Int
    let title: String
    let description: String
    let audioUrl: String
    let imageUrl: String
    let duration: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case audioUrl
        case imageUrl
        case duration
    }
}

/// API response wrapper for episodes endpoint
struct EpisodesResponse: Codable {
    let success: Bool
    let episodes: [Episode]?
    let error: String?
}
