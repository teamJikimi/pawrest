//
//  ImageCacheService.swift
//  pawrest
//
//  Created by 소은 on 5/21/26.
//

import SwiftData
import Foundation

@Model
public final class CachedImage {
    @Attribute(.unique) public var id: String
    public var imageData: Data
    public var uploadedURL: String?
    public var createdAt: Date
    
    public init(id: String, imageData: Data, uploadedURL: String? = nil) {
        self.id = id
        self.imageData = imageData
        self.uploadedURL = uploadedURL
        self.createdAt = Date()
    }
}

public protocol ImageCacheServiceProtocol {
    func cache(image: ImageUploadEntity) async throws
    func getUploadedURL(for imageId: String) async throws -> String?
    func updateURL(for imageId: String, url: String) async throws
}

public final class ImageCacheService: ImageCacheServiceProtocol {
    private let modelContext: ModelContext
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    public func cache(image: ImageUploadEntity) async throws {
        let cached = CachedImage(id: image.id.uuidString, imageData: image.data)
        modelContext.insert(cached)
        try modelContext.save()
    }
    
    public func getUploadedURL(for imageId: String) async throws -> String? {
        let descriptor = FetchDescriptor<CachedImage>(
            predicate: #Predicate { $0.id == imageId }
        )
        let results = try modelContext.fetch(descriptor)
        return results.first?.uploadedURL
    }
    
    public func updateURL(for imageId: String, url: String) async throws {
        let descriptor = FetchDescriptor<CachedImage>(
            predicate: #Predicate { $0.id == imageId }
        )
        let results = try modelContext.fetch(descriptor)
        if let cached = results.first {
            cached.uploadedURL = url
            try modelContext.save()
        }
    }
}
