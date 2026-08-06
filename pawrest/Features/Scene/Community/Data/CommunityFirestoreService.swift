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
    
    func updatePost(
        postID: String,
        title: String,
        content: String
    ) async throws {
        try await firestore
            .collection("posts")
            .document(postID)
            .updateData([
                "title": title,
                "content": content
            ])
    }
    
    func fetchLikedPostIDs(userID: String) async throws -> Set<String> {
        let snapshot = try await firestore
            .collectionGroup("likes")
            .whereField(FieldPath.documentID(), isEqualTo: userID)
            .getDocuments()

        return Set(
            snapshot.documents.compactMap {
                $0.reference.parent.parent?.documentID
            }
        )
    }
    
    func isPostLiked(
        postID: String,
        userID: String
    ) async throws -> Bool {
        let document = try await firestore
            .collection("posts")
            .document(postID)
            .collection("likes")
            .document(userID)
            .getDocument()

        return document.exists
    }
    
    func toggleLike(
        postID: String,
        userID: String,
        isLiked: Bool
    ) async throws {

        let postRef = firestore
            .collection("posts")
            .document(postID)

        let likeRef = postRef
            .collection("likes")
            .document(userID)

        try await firestore.runTransaction { transaction, errorPointer in

            do {
                let postSnapshot = try transaction.getDocument(postRef)

                let currentLikeCount =
                    postSnapshot.data()?["likeCount"] as? Int ?? 0

                if isLiked {
                    transaction.deleteDocument(likeRef)

                    transaction.updateData(
                        [
                            "likeCount": max(0, currentLikeCount - 1)
                        ],
                        forDocument: postRef
                    )
                } else {
                    transaction.setData(
                        [
                            "createdAt": Timestamp(date: Date())
                        ],
                        forDocument: likeRef
                    )

                    transaction.updateData(
                        [
                            "likeCount": currentLikeCount + 1
                        ],
                        forDocument: postRef
                    )
                }

                return nil

            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }
    }
}
