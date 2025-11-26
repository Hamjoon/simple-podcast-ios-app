import SwiftUI

/// Main tab view containing all podcast tabs
struct MainTabView: View {
    @State private var selectedTab: String = Podcast.filmClub.id

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(Podcast.allPodcasts) { podcast in
                PodcastTabContent(podcast: podcast)
                    .tabItem {
                        Label(podcast.name, systemImage: podcast.iconName)
                    }
                    .tag(podcast.id)
            }
        }
        .tint(Color.primaryGradientStart)
    }
}

/// Content view for each podcast tab
struct PodcastTabContent: View {
    let podcast: Podcast
    @StateObject private var viewModel: PodcastViewModel

    init(podcast: Podcast) {
        self.podcast = podcast
        _viewModel = StateObject(wrappedValue: PodcastViewModel(podcast: podcast))
    }

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: podcast.gradientColors.start),
                    Color(hex: podcast.gradientColors.end)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    PodcastHeaderView(podcast: podcast)

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
        .environmentObject(viewModel)
        .task {
            await viewModel.fetchEpisodes()
        }
    }
}

/// Header view with podcast title and subtitle
struct PodcastHeaderView: View {
    let podcast: Podcast

    var body: some View {
        VStack(spacing: 10) {
            Text(podcast.subtitle)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)

            Text(podcast.name)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(.vertical, 30)
    }
}

#Preview {
    MainTabView()
}
