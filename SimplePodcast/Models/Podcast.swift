import Foundation

/// Represents a podcast with its metadata
struct Podcast: Identifiable, Hashable {
    let id: String
    let name: String
    let subtitle: String
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
        iconName: "film",
        gradientColors: (start: "667eea", end: "764ba2")
    )

    static let radioBookClub = Podcast(
        id: "radio-book-club",
        name: "라디오 북클럽",
        subtitle: "MBC 라디오 북클럽",
        iconName: "headphones",
        gradientColors: (start: "11998e", end: "38ef7d")
    )

    static let seodam = Podcast(
        id: "seodam",
        name: "서담서담",
        subtitle: "책으로 읽는 내 마음",
        iconName: "book",
        gradientColors: (start: "ee9ca7", end: "ffdde1")
    )

    static let allPodcasts: [Podcast] = [.filmClub, .radioBookClub, .seodam]
}
