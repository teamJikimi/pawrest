//
//  CommunityFirestoreService.swift
//  pawrest
//
//  Created by Moon AYoung on 8/6/26.
//

import Foundation
import FirebaseFirestore

final class CommunityFirestoreService {

    private let firestore: Firestore

    init(
        firestore: Firestore = Firestore.firestore()
    ) {
        self.firestore = firestore
    }

    func fetchPosts() async throws -> [CommunityPostDTO] {
        let snapshot = try await firestore
            .collection("posts")
            .order(by: "createdAt", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap {
            CommunityPostDTO(document: $0)
        }
    }

    func createPost(
        authorID: String,
        authorName: String,
        title: String,
        content: String
    ) async throws -> CommunityPostDTO {
        let document = firestore
            .collection("posts")
            .document()

        let createdAt = Date()

        try await document.setData([
            "authorID": authorID,
            "authorName": authorName,
            "title": title,
            "content": content,
            "createdAt": Timestamp(date: createdAt),
            "imageURLs": [],
            "likeCount": 0,
            "commentCount": 0
        ])

        return CommunityPostDTO(
            id: document.documentID,
            authorID: authorID,
            authorName: authorName,
            authorProfileImageURL: nil,
            title: title,
            content: content,
            createdAt: createdAt,
            imageURLs: [],
            likeCount: 0,
            commentCount: 0
        )
    }
    
    func deletePost(postID: String) async throws {
        try await firestore
            .collection("posts")
            .document(postID)
            .delete()
    }
}
