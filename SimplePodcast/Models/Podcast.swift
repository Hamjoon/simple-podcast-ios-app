import Foundation

/// Represents a podcast with its metadata and RSS feed URL
struct Podcast: Identifiable, Hashable {
    let id: String
    let name: String
    let subtitle: String
    let rssURL: String
    let iconName: String
    let gradientColors: (start: String, end: String)

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Podcast, rhs: Podcast) -> Bool {
        lhs.id == rhs.id
    }
}

/// Predefined podcasts available in the app
extension Podcast {
    static let filmClub = Podcast(
        id: "film-club",
        name: "필름클럽",
        subtitle: "김혜리의 필름클럽",
        rssURL: "https://wizard2.sbs.co.kr/w3/podcast/V2000010143.xml",
        iconName: "film",
        gradientColors: (start: "667eea", end: "764ba2")
    )

    static let tasteOfTravel = Podcast(
        id: "taste-of-travel",
        name: "여행의 맛",
        subtitle: "노중훈의 여행의 맛",
        rssURL: "https://rss.art19.com/TASTE",
        iconName: "airplane",
        gradientColors: (start: "11998e", end: "38ef7d")
    )

    static let seodam = Podcast(
        id: "seodam",
        name: "서담서담",
        subtitle: "책으로 읽는 내 마음",
        rssURL: "https://rss.art19.com/SEODAM",
        iconName: "book",
        gradientColors: (start: "ee9ca7", end: "ffdde1")
    )

    static let allPodcasts: [Podcast] = [.filmClub, .tasteOfTravel, .seodam]
}
