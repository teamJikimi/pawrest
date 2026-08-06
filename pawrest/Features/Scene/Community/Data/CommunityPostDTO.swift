//
//  CommunityPostDTO.swift
//  pawrest
//
//  Created by Moon AYoung on 8/6/26.
//

import Foundation
import FirebaseFirestore

struct CommunityPostDTO {

    let id: String

    let authorID: String
    let authorName: String
    let authorProfileImageURL: String?

    let title: String
    let content: String

    let createdAt: Date

    let imageURLs: [String]

    let likeCount: Int
    let commentCount: Int
    
    init(
        id: String,
        authorID: String,
        authorName: String,
        authorProfileImageURL: String?,
        title: String,
        content: String,
        createdAt: Date,
        imageURLs: [String],
        likeCount: Int,
        commentCount: Int
    ) {
        self.id = id
        self.authorID = authorID
        self.authorName = authorName
        self.authorProfileImageURL = authorProfileImageURL
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.imageURLs = imageURLs
        self.likeCount = likeCount
        self.commentCount = commentCount
    }
}

// MARK: - Firestore Mapping

extension CommunityPostDTO {

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()

        guard
            let authorID = data["authorID"] as? String,
            let authorName = data["authorName"] as? String,
            let title = data["title"] as? String,
            let content = data["content"] as? String
        else {
            return nil
        }

        self.id = document.documentID
        self.authorID = authorID
        self.authorName = authorName
        self.authorProfileImageURL = data["authorProfileImageURL"] as? String

        self.title = title
        self.content = content

        if let timestamp = data["createdAt"] as? Timestamp {
            self.createdAt = timestamp.dateValue()
        } else {
            self.createdAt = Date()
        }

        self.imageURLs = data["imageURLs"] as? [String] ?? []
        self.likeCount = data["likeCount"] as? Int ?? 0
        self.commentCount = data["commentCount"] as? Int ?? 0
    }
}

// MARK: - Domain Mapping

extension CommunityPostDTO {

    func toDomain() -> Post {
        Post(
            id: id,
            author: Author(
                id: authorID,
                name: authorName,
                profileImageURL: authorProfileImageURL
            ),
            title: title,
            content: content,
            createdAt: createdAt,
            imageURLs: imageURLs,
            likeCount: likeCount,
            isLiked: false,
            comments: []
        )
    }
}
