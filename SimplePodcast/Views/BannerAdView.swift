import SwiftUI
import GoogleMobileAds

/// A SwiftUI wrapper for Google AdMob banner ads
struct BannerAdView: UIViewRepresentable {
    // AdMob Banner Ad Unit IDs
    // ⚠️ 경고: 개발/테스트 중에는 반드시 테스트 광고 단위를 사용해야 합니다.
    // 실제 광고 단위로 테스트하면 계정이 정지될 수 있습니다.
    private let testAdUnitID = "ca-app-pub-3940256099942544/2435281174" // Google 제공 테스트 ID
    private let productionAdUnitID = "ca-app-pub-4520024012612955/7317728482"
    
    private var adUnitID: String {
        #if DEBUG
        return testAdUnitID
        #else
        return productionAdUnitID
        #endif
    }

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
