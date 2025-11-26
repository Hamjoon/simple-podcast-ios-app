import SwiftUI

/// Main content view of the podcast app
struct ContentView: View {
    @EnvironmentObject var viewModel: PodcastViewModel

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "667eea"),
                    Color(hex: "764ba2")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    HeaderView()

                    // Main content card
                    VStack(spacing: 30) {
                        PlayerView()
                        EpisodeListView()
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .task {
            await viewModel.fetchEpisodes()
        }
    }
}

/// Header view with title and subtitle
struct HeaderView: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("header.title")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)

            Text("header.subtitle")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(.vertical, 30)
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    static let primaryGradientStart = Color(hex: "667eea")
    static let primaryGradientEnd = Color(hex: "764ba2")
    static let activeEpisode = Color(hex: "667eea")
}

#Preview {
    ContentView()
        .environmentObject(PodcastViewModel())
}
