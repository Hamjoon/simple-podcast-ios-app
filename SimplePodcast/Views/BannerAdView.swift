import SwiftUI
import GoogleMobileAds

/// A SwiftUI wrapper for Google AdMob banner ads
struct BannerAdView: UIViewRepresentable {
    // Production Ad Unit ID
    private let adUnitID = "ca-app-pub-4520024012612955/7317728482"

    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView()
        bannerView.adUnitID = adUnitID

        // Use adaptive banner size for optimal display
        let viewWidth = UIScreen.main.bounds.width
        bannerView.adSize = currentOrientationAnchoredAdaptiveBanner(width: viewWidth)

        // Find the root view controller to set as the banner's root
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            bannerView.rootViewController = rootViewController
        }

        // Load the ad
        bannerView.load(Request())

        return bannerView
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        // No updates needed
    }
}

#Preview {
    BannerAdView()
        .frame(height: 50)
}
