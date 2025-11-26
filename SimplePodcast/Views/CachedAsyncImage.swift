import SwiftUI

/// Image loader with caching support
@MainActor
final class CachedImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false

    private let cache = ImageCache.shared
    private var currentURL: URL?
    private var loadTask: Task<Void, Never>?

    func load(from url: URL?) {
        // Cancel previous task if URL changed
        if currentURL != url {
            loadTask?.cancel()
            loadTask = nil
        }

        guard let url = url else {
            image = nil
            isLoading = false
            return
        }

        currentURL = url

        // Check cache first
        if let cachedImage = cache.image(for: url) {
            image = cachedImage
            isLoading = false
            return
        }

        // Load from network
        isLoading = true
        loadTask = Task {
            await loadImage(from: url)
        }
    }

    private func loadImage(from url: URL) async {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard !Task.isCancelled else { return }

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let loadedImage = UIImage(data: data) else {
                isLoading = false
                return
            }

            // Store in cache
            cache.store(loadedImage, for: url)

            // Update UI on main thread
            image = loadedImage
            isLoading = false
        } catch {
            guard !Task.isCancelled else { return }
            isLoading = false
        }
    }

    func cancel() {
        loadTask?.cancel()
        loadTask = nil
    }
}

/// A cached async image view that loads and caches images efficiently
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    @StateObject private var loader = CachedImageLoader()

    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder

    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if let uiImage = loader.image {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
            }
        }
        .onAppear {
            loader.load(from: url)
        }
        .onChange(of: url) { newURL in
            loader.load(from: newURL)
        }
        .onDisappear {
            // Don't cancel immediately to allow for quick scrolling back
        }
    }
}

/// Convenience initializer for simple placeholder
extension CachedAsyncImage where Placeholder == ProgressView<EmptyView, EmptyView> {
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content
    ) {
        self.init(
            url: url,
            content: content,
            placeholder: { ProgressView() }
        )
    }
}
