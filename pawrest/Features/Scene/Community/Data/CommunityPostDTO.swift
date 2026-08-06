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
            id: UUID.deterministic(from: id),
            author: Author(
                id: UUID.deterministic(from: authorID),
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

// MARK: - UUID Helper

private extension UUID {

    static func deterministic(from string: String) -> UUID {
        var hash = Array(repeating: UInt8(0), count: 16)

        for (index, byte) in string.utf8.enumerated() {
            hash[index % 16] = hash[index % 16] &+ byte
        }

        let uuid = uuid_t(
            hash[0], hash[1], hash[2], hash[3],
            hash[4], hash[5], hash[6], hash[7],
            hash[8], hash[9], hash[10], hash[11],
            hash[12], hash[13], hash[14], hash[15]
        )

        return UUID(uuid: uuid)
    }
}
