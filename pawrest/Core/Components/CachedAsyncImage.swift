//
//  CachedAsyncImage.swift
//  pawrest
//
//  Created by Moon Ayoung on 9/21/26.
//

import SwiftUI
import ImageIO

// MARK: - Cache

final class ImageCacheStore {
    static let shared = ImageCacheStore()
    
    let cache = NSCache<NSString, UIImage>()
    
    let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,
            diskCapacity: 300 * 1024 * 1024
        )
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        return URLSession(configuration: configuration)
    }()
    
    private init() {
        cache.countLimit = 200
        cache.totalCostLimit = 100 * 1024 * 1024
    }
}

// MARK: - Downsampler

enum ImageDownsampler {
    nonisolated static func downsample(data: Data, maxPixelSize: CGFloat) -> UIImage? {
        let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithData(data as CFData, sourceOptions) else {
            return nil
        }
        
        let thumbnailOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ] as CFDictionary
        
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbnailOptions) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}

// MARK: - View

struct CachedAsyncImage<Placeholder: View>: View {
    let url: URL?
    let contentMode: ContentMode
    var maxPixelSize: CGFloat = 1280
    @ViewBuilder let placeholder: () -> Placeholder
    
    @State private var image: UIImage?
    
    private var cacheKey: NSString? {
        url.map { "\($0.absoluteString)#\(Int(maxPixelSize))" as NSString }
    }
    
    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                placeholder()
            }
        }
        .task(id: cacheKey) {
            await load()
        }
    }
    
    private func load() async {
        guard let url, let cacheKey else {
            image = nil
            return
        }
        
        let cache = ImageCacheStore.shared.cache
        if let cached = cache.object(forKey: cacheKey) {
            image = cached
            return
        }
        
        image = nil
        
        guard let (data, _) = try? await ImageCacheStore.shared.session.data(from: url) else {
            return
        }
        
        let pixelSize = maxPixelSize
        let downsampled = await Task.detached(priority: .userInitiated) {
            ImageDownsampler.downsample(data: data, maxPixelSize: pixelSize)
        }.value
        
        guard let downsampled, !Task.isCancelled else { return }
        
        let cost = downsampled.cgImage.map { $0.bytesPerRow * $0.height } ?? 0
        cache.setObject(downsampled, forKey: cacheKey, cost: cost)
        image = downsampled
    }
}
