//
//  CachedAsyncImage.swift
//  pawrest
//
//  Created by Moon Ayoung on 9/21/26.
//

import SwiftUI

// MARK: - Cache

final class ImageCacheStore {
    static let shared = ImageCacheStore()
    private init() {
        cache.countLimit = 200
        cache.totalCostLimit = 100 * 1024 * 1024
    }
    
    let cache = NSCache<NSURL, UIImage>()
}

// MARK: - View

struct CachedAsyncImage<Placeholder: View>: View {
    
    let url: URL?
    let contentMode: ContentMode
    @ViewBuilder let placeholder: () -> Placeholder
    
    @State private var image: UIImage?
    @State private var isLoading = false
    
    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                placeholder()
                    .task(id: url) {
                        await load()
                    }
            }
        }
    }
    
    private func load() async {
        guard let url, !isLoading else { return }
        
        let cache = ImageCacheStore.shared.cache
        
        if let cached = cache.object(forKey: url as NSURL) {
            self.image = cached
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let downloaded = UIImage(data: data) else { return }
            cache.setObject(downloaded, forKey: url as NSURL)
            await MainActor.run {
                self.image = downloaded
            }
        } catch {
            return
        }
    }
}
