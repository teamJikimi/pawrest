//
//  CommunityFirestoreService.swift
//  pawrest
//
//  Created by Moon AYoung on 8/6/26.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

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
        postID: String,
        authorID: String,
        authorName: String,
        title: String,
        content: String,
        imageURLs: [String]
    )
    async throws -> CommunityPostDTO {
        let document = firestore
            .collection("posts")
            .document(postID)

        let createdAt = Date()

        try await document.setData([
            "authorID": authorID,
            "authorName": authorName,
            "title": title,
            "content": content,
            "createdAt": Timestamp(date: createdAt),
            "imageURLs": imageURLs,
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
            imageURLs: imageURLs,
            likeCount: 0,
            commentCount: 0
        )
    }
    
    func updatePost(
        postID: String,
        title: String,
        content: String,
        imageURLs: [String]
    ) async throws {
        try await firestore
            .collection("posts")
            .document(postID)
            .updateData([
                "title": title,
                "content": content,
                "imageURLs": imageURLs
            ])
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
    
    func fetchComments(
        postID: String
    ) async throws -> [CommunityCommentDTO] {

        let snapshot = try await firestore
            .collection("posts")
            .document(postID)
            .collection("comments")
            .order(by: "createdAt", descending: false)
            .getDocuments()

        return snapshot.documents.compactMap {
            CommunityCommentDTO(document: $0)
        }
    }
    
    func createComment(
        postID: String,
        authorID: String,
        authorName: String,
        content: String,
        parentCommentID: UUID?
    ) async throws -> CommunityCommentDTO {

        let commentID = UUID()

        let postRef = firestore
            .collection("posts")
            .document(postID)

        let commentRef = postRef
            .collection("comments")
            .document(commentID.uuidString)

        let createdAt = Date()

        var data: [String: Any] = [
            "authorID": authorID,
            "authorName": authorName,
            "content": content,
            "createdAt": Timestamp(date: createdAt)
        ]

        if let parentCommentID {
            data["parentCommentID"] = parentCommentID.uuidString
        }

        try await firestore.runTransaction { transaction, errorPointer in
            do {
                let postSnapshot = try transaction.getDocument(postRef)

                let currentCommentCount =
                    postSnapshot.data()?["commentCount"] as? Int ?? 0

                transaction.setData(
                    data,
                    forDocument: commentRef
                )

                transaction.updateData(
                    [
                        "commentCount": currentCommentCount + 1
                    ],
                    forDocument: postRef
                )

                return nil

            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }

        return CommunityCommentDTO(
            id: commentID,
            authorID: authorID,
            authorName: authorName,
            authorProfileImageURL: nil,
            content: content,
            createdAt: createdAt,
            parentCommentID: parentCommentID
        )
    }
    
    func deleteComment(
        postID: String,
        commentID: UUID
    ) async throws {

        let postRef = firestore
            .collection("posts")
            .document(postID)

        let commentRef = postRef
            .collection("comments")
            .document(commentID.uuidString)

        try await firestore.runTransaction { transaction, errorPointer in
            do {
                let postSnapshot = try transaction.getDocument(postRef)

                let currentCommentCount =
                    postSnapshot.data()?["commentCount"] as? Int ?? 0

                transaction.deleteDocument(commentRef)

                transaction.updateData(
                    [
                        "commentCount": max(0, currentCommentCount - 1)
                    ],
                    forDocument: postRef
                )

                return nil

            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }
    }
    
    func updateComment(
        postID: String,
        commentID: UUID,
        content: String
    ) async throws {

        try await firestore
            .collection("posts")
            .document(postID)
            .collection("comments")
            .document(commentID.uuidString)
            .updateData([
                "content": content
            ])
    }
    
    func deletePostImages(imageURLs: [String]) async throws {
        let storage = Storage.storage()
        
        for urlString in imageURLs {
            guard let url = URL(string: urlString) else { continue }
            let path = url.path
            
            guard let range = path.range(of: "community/") else {
                continue
            }

            let storagePath = String(path[range.lowerBound...])
            
            do {
                try await storage.reference().child(storagePath).delete()
            } catch {
                print("⚠️ 이미지 삭제 실패: \(storagePath)")
            }
        }
    }
}
