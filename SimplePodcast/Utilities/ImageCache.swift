import Foundation
import UIKit

/// Image cache manager with memory and disk caching support
final class ImageCache {
    static let shared = ImageCache()

    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let ioQueue = DispatchQueue(label: "com.simplepodcast.imagecache.io", qos: .utility)

    private init() {
        // Configure memory cache
        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50MB

        // Set up disk cache directory
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        cacheDirectory = cachesDirectory.appendingPathComponent("ImageCache", isDirectory: true)

        // Create cache directory if it doesn't exist
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)

        // Clear old cache on app launch (files older than 7 days)
        cleanOldCache()
    }

    /// Get image from cache (memory first, then disk)
    func image(for url: URL) -> UIImage? {
        let key = cacheKey(for: url)

        // Check memory cache first
        if let cachedImage = memoryCache.object(forKey: key as NSString) {
            return cachedImage
        }

        // Check disk cache
        let filePath = cacheFilePath(for: key)
        if let data = try? Data(contentsOf: filePath),
           let image = UIImage(data: data) {
            // Store in memory cache for faster access next time
            memoryCache.setObject(image, forKey: key as NSString, cost: data.count)
            return image
        }

        return nil
    }

    /// Store image in both memory and disk cache
    func store(_ image: UIImage, for url: URL) {
        let key = cacheKey(for: url)

        // Store in memory cache
        if let data = image.jpegData(compressionQuality: 0.8) {
            memoryCache.setObject(image, forKey: key as NSString, cost: data.count)

            // Store on disk asynchronously
            let filePath = cacheFilePath(for: key)
            ioQueue.async {
                try? data.write(to: filePath)
            }
        }
    }

    /// Generate a cache key from URL
    private func cacheKey(for url: URL) -> String {
        // Use SHA256-like simple hash of URL string
        let urlString = url.absoluteString
        var hash: UInt64 = 5381
        for char in urlString.utf8 {
            hash = ((hash << 5) &+ hash) &+ UInt64(char)
        }
        return String(format: "%016llx", hash)
    }

    /// Get file path for cached image
    private func cacheFilePath(for key: String) -> URL {
        cacheDirectory.appendingPathComponent(key)
    }

    /// Clean cache files older than 7 days
    private func cleanOldCache() {
        ioQueue.async { [weak self] in
            guard let self = self else { return }

            let expirationDate = Date().addingTimeInterval(-7 * 24 * 60 * 60)

            guard let files = try? self.fileManager.contentsOfDirectory(
                at: self.cacheDirectory,
                includingPropertiesForKeys: [.contentModificationDateKey]
            ) else { return }

            for file in files {
                guard let attributes = try? self.fileManager.attributesOfItem(atPath: file.path),
                      let modificationDate = attributes[.modificationDate] as? Date,
                      modificationDate < expirationDate else {
                    continue
                }
                try? self.fileManager.removeItem(at: file)
            }
        }
    }

    /// Clear all cached images
    func clearCache() {
        memoryCache.removeAllObjects()
        ioQueue.async { [weak self] in
            guard let self = self else { return }
            try? self.fileManager.removeItem(at: self.cacheDirectory)
            try? self.fileManager.createDirectory(at: self.cacheDirectory, withIntermediateDirectories: true)
        }
    }
}
