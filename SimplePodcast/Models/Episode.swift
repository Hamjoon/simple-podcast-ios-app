import Foundation

/// Represents a single podcast episode
struct Episode: Identifiable, Codable, Equatable {
    let id: Int
    let title: String
    let description: String
    let audioUrl: String
    let imageUrl: String
    let duration: String
    let pubDate: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case audioUrl
        case imageUrl
        case duration
        case pubDate
    }

    /// Formatted publish date for display (YYYY.MM.DD)
    var formattedPubDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        // Try RFC 822 format first (e.g., "Mon, 25 Nov 2024 10:00:00 +0900")
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"

        if let date = dateFormatter.date(from: pubDate) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy.MM.dd"
            return outputFormatter.string(from: date)
        }

        // If parsing fails, return original string
        return pubDate
    }
}

/// API response wrapper for episodes endpoint
struct EpisodesResponse: Codable {
    let success: Bool
    let episodes: [Episode]?
    let error: String?
}
