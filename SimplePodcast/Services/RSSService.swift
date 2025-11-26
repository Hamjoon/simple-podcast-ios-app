import Foundation

/// Service for fetching and parsing RSS podcast feeds
actor RSSService {
    static let shared = RSSService()

    private init() {}

    /// Fetches episodes from an RSS feed URL
    /// - Parameter urlString: The RSS feed URL
    /// - Returns: Array of Episode objects parsed from the feed
    func fetchEpisodes(from urlString: String) async throws -> [Episode] {
        guard let url = URL(string: urlString) else {
            throw RSSError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw RSSError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw RSSError.httpError(statusCode: httpResponse.statusCode)
        }

        let parser = RSSParser()
        return try parser.parse(data: data)
    }
}

/// Errors that can occur during RSS operations
enum RSSError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case parsingError(String)
    case noData

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid RSS feed URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .parsingError(let message):
            return "Parsing error: \(message)"
        case .noData:
            return "No data received"
        }
    }
}

/// RSS feed parser using XMLParser
class RSSParser: NSObject, XMLParserDelegate {
    private var episodes: [Episode] = []
    private var currentElement = ""
    private var currentTitle = ""
    private var currentDescription = ""
    private var currentAudioUrl = ""
    private var currentImageUrl = ""
    private var currentDuration = ""
    private var isInsideItem = false
    private var isInsideImage = false
    private var channelImageUrl = ""
    private var episodeId = 0

    func parse(data: Data) throws -> [Episode] {
        episodes = []
        episodeId = 0

        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()

        if let error = parser.parserError {
            throw RSSError.parsingError(error.localizedDescription)
        }

        return episodes
    }

    // MARK: - XMLParserDelegate

    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?,
                attributes attributeDict: [String: String] = [:]) {

        currentElement = elementName

        switch elementName {
        case "item":
            isInsideItem = true
            currentTitle = ""
            currentDescription = ""
            currentAudioUrl = ""
            currentImageUrl = ""
            currentDuration = ""

        case "enclosure":
            if isInsideItem, let url = attributeDict["url"] {
                currentAudioUrl = url
            }

        case "itunes:image":
            if isInsideItem, let href = attributeDict["href"] {
                currentImageUrl = href
            } else if !isInsideItem, let href = attributeDict["href"] {
                channelImageUrl = href
            }

        case "image":
            if !isInsideItem {
                isInsideImage = true
            }

        case "media:content", "media:thumbnail":
            if isInsideItem, let url = attributeDict["url"], currentImageUrl.isEmpty {
                currentImageUrl = url
            }

        default:
            break
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if isInsideItem {
            switch currentElement {
            case "title":
                currentTitle += trimmed
            case "description", "itunes:summary":
                if currentDescription.isEmpty {
                    currentDescription += trimmed
                }
            case "itunes:duration":
                currentDuration += trimmed
            default:
                break
            }
        } else if isInsideImage && currentElement == "url" {
            channelImageUrl += trimmed
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?) {

        if elementName == "item" {
            // Use channel image if episode doesn't have its own
            let imageUrl = currentImageUrl.isEmpty ? channelImageUrl : currentImageUrl

            // Clean description: remove HTML tags
            let cleanDescription = currentDescription
                .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespacesAndNewlines)

            let episode = Episode(
                id: episodeId,
                title: currentTitle,
                description: cleanDescription,
                audioUrl: currentAudioUrl,
                imageUrl: imageUrl,
                duration: formatDuration(currentDuration)
            )

            episodes.append(episode)
            episodeId += 1
            isInsideItem = false
        } else if elementName == "image" {
            isInsideImage = false
        }
    }

    /// Format duration string to consistent format
    private func formatDuration(_ duration: String) -> String {
        // Handle HH:MM:SS format
        if duration.contains(":") {
            return duration
        }

        // Handle seconds format
        if let seconds = Int(duration) {
            let hours = seconds / 3600
            let minutes = (seconds % 3600) / 60
            let secs = seconds % 60

            if hours > 0 {
                return String(format: "%d:%02d:%02d", hours, minutes, secs)
            } else {
                return String(format: "%d:%02d", minutes, secs)
            }
        }

        return duration.isEmpty ? "Unknown" : duration
    }
}
