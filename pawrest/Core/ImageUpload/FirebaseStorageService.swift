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
        metadata.contentType = "image/\(image.fileExtension)"
        
        _ = try await storageRef.putDataAsync(image.data, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()
        return downloadURL.absoluteString
    }
}
