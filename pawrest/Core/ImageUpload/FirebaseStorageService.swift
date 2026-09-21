//
//  FirebaseStorageService.swift
//  pawrest
//
//  Created by 소은 on 5/21/26.
//

import FirebaseStorage
import Foundation

public protocol FirebaseStorageServiceProtocol {
    func upload(image: ImageUploadEntity, to path: StoragePath) async throws -> String
    func delete(url: String) async throws
    func delete(urls: [String]) async
}

public final class FirebaseStorageService: FirebaseStorageServiceProtocol {
    private let storage: Storage
    
    public init() {
        self.storage = Storage.storage()
    }
    
    public func upload(
        image: ImageUploadEntity,
        to path: StoragePath
    ) async throws -> String {
        let storageRef = storage.reference().child(path.path + ".\(image.fileExtension)")
        
        let metadata = StorageMetadata()
        metadata.contentType = image.contentType
        metadata.cacheControl = "public, max-age=31536000"
        
        _ = try await storageRef.putDataAsync(image.data, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()
        return downloadURL.absoluteString
    }
    
    public func delete(url: String) async throws {
        guard let path = storagePath(from: url) else { return }
        
        do {
            try await storage.reference().child(path).delete()
        } catch StorageError.objectNotFound {
            return
        }
    }
    
    public func delete(urls: [String]) async {
        await withTaskGroup(of: Void.self) { group in
            for url in urls {
                group.addTask {
                    try? await self.delete(url: url)
                }
            }
        }
    }
    
    private func storagePath(from urlString: String) -> String? {
        guard let url = URL(string: urlString) else { return nil }
        
        let path = url.path(percentEncoded: false)
        guard let range = path.range(of: "/o/") else { return nil }
        
        return String(path[range.upperBound...])
    }
}
