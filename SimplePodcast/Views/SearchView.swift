import SwiftUI

/// Main search view for searching episodes across all podcasts
struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @Binding var selectedTab: String

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text("검색")
                .font(.system(size: 34, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 4)

            // Search bar
            SearchBarView(text: $viewModel.searchText)

            // Content based on state
            SearchContentView(viewModel: viewModel, selectedTab: $selectedTab)
        }
        .background(Color(UIColor.systemBackground))
        .task {
            await viewModel.fetchAllEpisodes()
        }
    }
}

/// Content view that displays based on search state
struct SearchContentView: View {
    @ObservedObject var viewModel: SearchViewModel
    @Binding var selectedTab: String

    var body: some View {
        switch viewModel.loadingState {
        case .idle, .loading:
            LoadingStateView()

        case .ready:
            if viewModel.searchText.isEmpty {
                EmptySearchPromptView()
            } else if viewModel.searchResults.isEmpty {
                NoResultsView(query: viewModel.searchText)
            } else {
                SearchResultsListView(viewModel: viewModel, selectedTab: $selectedTab)
            }

        case .error(let message):
            ErrorStateView(message: message) {
                Task {
                    await viewModel.fetchAllEpisodes()
                }
            }
        }
    }
}

/// Loading state view
struct LoadingStateView: View {
    var body: some View {
        Spacer()
        ProgressView()
            .scaleEffect(1.5)
        Spacer()
    }
}

/// Empty search prompt view
struct EmptySearchPromptView: View {
    var body: some View {
        Spacer()
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.gray)

            Text("에피소드를 검색해 보세요")
                .font(.system(size: 17))
                .foregroundColor(.secondary)
        }
        Spacer()
    }
}

/// No results view
struct NoResultsView: View {
    let query: String

    var body: some View {
        Spacer()
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.gray)

            Text("검색 결과가 없습니다")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.primary)

            Text("\"\(query)\"에 대한 결과를 찾을 수 없습니다")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
        Spacer()
    }
}

/// Error state view
struct ErrorStateView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        Spacer()
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text("오류가 발생했습니다")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.primary)

            Text(message)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button(action: retryAction) {
                Text("다시 시도")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.primaryGradientStart)
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal, 40)
        Spacer()
    }
}

/// Search results list view
struct SearchResultsListView: View {
    @ObservedObject var viewModel: SearchViewModel
    @Binding var selectedTab: String

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.searchResults) { result in
                    SearchResultRowView(
                        searchResult: result,
                        isCurrentEpisode: viewModel.isCurrentEpisode(result.episode)
                    )
                    .onTapGesture {
                        viewModel.play(episode: result.episode)
                        // Switch to the podcast's tab
                        selectedTab = result.podcast.id
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    SearchView(selectedTab: .constant("film-club"))
}
