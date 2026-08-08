//
//  ImageUploadEntity.swift
//  pawrest
//
//  Created by 소은 on 5/21/26.
//

import Foundation

public struct ImageUploadEntity: Identifiable, Sendable {
    public let id: UUID
    public let data: Data
    public let fileExtension: String  // "jpg" or "png"
    
    public nonisolated init(data: Data, fileExtension: String) {
        self.id = UUID()
        self.data = data
        self.fileExtension = fileExtension
    }
}

// Firebase Storage 경로 정의
public enum StoragePath {
    case journal(userId: String, imageId: String)
    case profile(userId: String)
    case community(postID: String, imageID: String)
    
    public var path: String {
        switch self {
        case .journal(let userId, let imageId):
            return "users/\(userId)/journals/\(imageId)"
        case .profile(let userId):
            return "users/\(userId)/profile.jpg"
        case .community(let postID, let imageID):
                    return "community/\(postID)/\(imageID)"
        }
    }
}
