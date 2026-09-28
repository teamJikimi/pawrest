//
//  CommunityCommentDTO.swift
//  pawrest
//
//  Created by Moon AYoung on 8/7/26.
//

import Foundation
import FirebaseFirestore

struct CommunityCommentDTO {
    
    let id: UUID
    
    let authorID: String
    let authorName: String
    
    let content: String
    let createdAt: Date
    
    let parentCommentID: UUID?
}

// MARK: - Firestore Mapping

extension CommunityCommentDTO {
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard
            let id = UUID(uuidString: document.documentID),
            let authorID = data["authorID"] as? String,
            let authorName = data["authorName"] as? String,
            let content = data["content"] as? String
        else {
            return nil
        }
        
        self.id = id
        self.authorID = authorID
        self.authorName = authorName
        self.content = content
        
        if let timestamp = data["createdAt"] as? Timestamp {
            self.createdAt = timestamp.dateValue()
        } else {
            self.createdAt = Date()
        }
        
        if let parentIDString = data["parentCommentID"] as? String {
            self.parentCommentID = UUID(uuidString: parentIDString)
        } else {
            self.parentCommentID = nil
        }
    }
}

// MARK: - Domain Mapping

extension CommunityCommentDTO {
    
    func toDomain(
        replies: [Comment] = [],
        profile: RemoteUserProfile? = nil
    ) -> Comment {
            Comment(
                id: id,
                content: content,
                author: Author(
                    id: authorID,
                    name: profile?.nickname ?? authorName,
                    profileImageURL: profile?.profileImageURL
                ),
                createdAt: createdAt,
                replies: replies
            )
        }
}
