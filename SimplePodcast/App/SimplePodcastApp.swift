import SwiftUI
import GoogleMobileAds

@main
struct SimplePodcastApp: App {
    init() {
        MobileAds.shared.start()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}
