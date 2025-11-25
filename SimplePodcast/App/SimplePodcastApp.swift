import SwiftUI

@main
struct SimplePodcastApp: App {
    @StateObject private var viewModel = PodcastViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
