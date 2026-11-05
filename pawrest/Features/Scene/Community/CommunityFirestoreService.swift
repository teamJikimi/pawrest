//
//  CommunityFirestoreService.swift
//  pawrest
//
//  Created by 소은 on 11/2/26.
//

import Foundation
import FirebaseFirestore

final class CommunityFirestoreService {

    private let firestore: Firestore

    init(firestore: Firestore = Firestore.firestore()) {
        self.firestore = firestore
    }

    func fetchPosts() async throws -> [CommunityPostDTO] {
        let snapshot = try await firestore
            .collection("posts")
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { CommunityPostDTO(document: $0) }
    }
    
    func fetchPost(postID: String) async throws -> CommunityPostDTO? {
        let doc = try await firestore.collection("posts").document(postID).getDocument()
        guard doc.exists else { return nil }
        return CommunityPostDTO(documentSnapshot: doc)
    }

    func createPost(
        postID: String,
        authorID: String,
        authorName: String,
        title: String,
        content: String,
        imageURLs: [String]
    ) async throws -> CommunityPostDTO {
        let document = firestore.collection("posts").document(postID)
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
        try await firestore.collection("posts").document(postID).delete()
    }

    func fetchLikedPostIDs(userID: String) async throws -> Set<String> {
        let snapshot = try await firestore
            .collectionGroup("likes")
            .whereField(FieldPath.documentID(), isEqualTo: userID)
            .getDocuments()
        return Set(snapshot.documents.compactMap {
            $0.reference.parent.parent?.documentID
        })
    }

    func isPostLiked(postID: String, userID: String) async throws -> Bool {
        let document = try await firestore
            .collection("posts")
            .document(postID)
            .collection("likes")
            .document(userID)
            .getDocument()
        return document.exists
    }

    func toggleLike(postID: String, userID: String, isLiked: Bool, senderName: String) async throws {
        let postRef = firestore.collection("posts").document(postID)
        let likeRef = postRef.collection("likes").document(userID)

        var postAuthorID: String? = nil

        _ = try await firestore.runTransaction { transaction, errorPointer in
            do {
                let postSnapshot = try transaction.getDocument(postRef)
                let currentLikeCount = postSnapshot.data()?["likeCount"] as? Int ?? 0
                postAuthorID = postSnapshot.data()?["authorID"] as? String
                if isLiked {
                    transaction.deleteDocument(likeRef)
                    transaction.updateData(["likeCount": max(0, currentLikeCount - 1)], forDocument: postRef)
                } else {
                    transaction.setData(["createdAt": Timestamp(date: Date())], forDocument: likeRef)
                    transaction.updateData(["likeCount": currentLikeCount + 1], forDocument: postRef)
                }
                return nil
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }

        if !isLiked, let authorID = postAuthorID, authorID != userID {
            do {
                try await createNotification(
                    targetUserID: authorID,
                    type: "like",
                    senderName: senderName,
                    postID: postID,
                    body: "회원님의 게시글을 좋아합니다."
                )
            } catch {
                print("[Notification] 좋아요 알림 전송 실패: \(error)")
            }
        }
    }

    func fetchComments(postID: String) async throws -> [CommunityCommentDTO] {
        let snapshot = try await firestore
            .collection("posts")
            .document(postID)
            .collection("comments")
            .order(by: "createdAt", descending: false)
            .getDocuments()
        return snapshot.documents.compactMap { CommunityCommentDTO(document: $0) }
    }

    nonisolated func observeComments(postID: String) -> AsyncStream<[CommunityCommentDTO]> {
        AsyncStream { continuation in
            Task { @MainActor in
                let listener = self.firestore
                    .collection("posts")
                    .document(postID)
                    .collection("comments")
                    .order(by: "createdAt", descending: false)
                    .addSnapshotListener { snapshot, _ in
                        guard let snapshot else { return }
                        let dtos = snapshot.documents.compactMap { CommunityCommentDTO(document: $0) }
                        continuation.yield(dtos)
                    }
                continuation.onTermination = { _ in listener.remove() }
            }
        }
    }

    func createComment(
        postID: String,
        authorID: String,
        authorName: String,
        authorProfileImageURL: String?,
        content: String,
        parentCommentID: UUID?
    ) async throws -> CommunityCommentDTO {
        let commentID = UUID()
        let postRef = firestore.collection("posts").document(postID)
        let commentRef = postRef.collection("comments").document(commentID.uuidString)
        let createdAt = Date()
        var data: [String: Any] = [
            "authorID": authorID,
            "authorName": authorName,
            "content": content,
            "createdAt": Timestamp(date: createdAt)
        ]
        if let authorProfileImageURL {
            data["authorProfileImageURL"] = authorProfileImageURL
        }
        if let parentCommentID {
            data["parentCommentID"] = parentCommentID.uuidString
        }

        var postAuthorID: String? = nil

        _ = try await firestore.runTransaction { transaction, errorPointer in
            do {
                let postSnapshot = try transaction.getDocument(postRef)
                let currentCommentCount = postSnapshot.data()?["commentCount"] as? Int ?? 0
                postAuthorID = postSnapshot.data()?["authorID"] as? String
                transaction.setData(data, forDocument: commentRef)
                transaction.updateData(["commentCount": currentCommentCount + 1], forDocument: postRef)
                return nil
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }

        if let targetUserID = postAuthorID, targetUserID != authorID {
            print("[Notification] 알림 전송 시도 - targetUserID: \(targetUserID)")
            do {
                try await createNotification(
                    targetUserID: targetUserID,
                    type: "comment",
                    senderName: authorName,
                    postID: postID,
                    body: content
                )
                print("[Notification] 알림 전송 완료")
            } catch {
                print("[Notification] 알림 전송 실패: \(error)")
            }
        }

        return CommunityCommentDTO(
            id: commentID,
            authorID: authorID,
            authorName: authorName,
            authorProfileImageURL: authorProfileImageURL,
            content: content,
            createdAt: createdAt,
            parentCommentID: parentCommentID
        )
    }

    func deleteComment(postID: String, commentID: UUID) async throws {
        let postRef = firestore.collection("posts").document(postID)
        let commentsRef = postRef.collection("comments")
        let repliesSnapshot = try await commentsRef
            .whereField("parentCommentID", isEqualTo: commentID.uuidString)
            .getDocuments()
        let batch = firestore.batch()
        batch.deleteDocument(commentsRef.document(commentID.uuidString))
        repliesSnapshot.documents.forEach { batch.deleteDocument($0.reference) }
        batch.updateData(
            ["commentCount": FieldValue.increment(Int64(-(1 + repliesSnapshot.count)))],
            forDocument: postRef
        )
        try await batch.commit()
    }

    func hasComment(postID: String, authorID: String) async throws -> Bool {
        let snapshot = try await firestore
            .collection("posts")
            .document(postID)
            .collection("comments")
            .whereField("authorID", isEqualTo: authorID)
            .limit(to: 1)
            .getDocuments()
        return !snapshot.isEmpty
    }

    func updateComment(postID: String, commentID: UUID, content: String) async throws {
        try await firestore
            .collection("posts")
            .document(postID)
            .collection("comments")
            .document(commentID.uuidString)
            .updateData(["content": content])
    }

    // MARK: - Report

    func createReport(
        reporterID: String,
        targetType: String,
        targetID: String,
        targetAuthorID: String,
        reason: String
    ) async throws {
        try await firestore
            .collection("reports")
            .document(UUID().uuidString)
            .setData([
                "reporterID": reporterID,
                "targetType": targetType,
                "targetID": targetID,
                "targetAuthorID": targetAuthorID,
                "reason": reason,
                "createdAt": Timestamp(date: Date())
            ])
    }

    func hasReported(reporterID: String, targetID: String) async throws -> Bool {
        let snapshot = try await firestore
            .collection("reports")
            .whereField("reporterID", isEqualTo: reporterID)
            .whereField("targetID", isEqualTo: targetID)
            .limit(to: 1)
            .getDocuments()
        return !snapshot.isEmpty
    }

    // MARK: - Block

    func blockUser(currentUserID: String, blockedUserID: String, blockedUserName: String) async throws {
        try await firestore
            .collection("users")
            .document(currentUserID)
            .collection("blocks")
            .document(blockedUserID)
            .setData(["blockedUserName": blockedUserName, "createdAt": Timestamp(date: Date())])
    }

    func unblockUser(currentUserID: String, blockedUserID: String) async throws {
        try await firestore
            .collection("users")
            .document(currentUserID)
            .collection("blocks")
            .document(blockedUserID)
            .delete()
    }

    func fetchBlockedUsers(currentUserID: String) async throws -> [(id: String, name: String)] {
        let snapshot = try await firestore
            .collection("users")
            .document(currentUserID)
            .collection("blocks")
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { doc in
            let name = doc.data()["blockedUserName"] as? String ?? ""
            return (id: doc.documentID, name: name)
        }
    }

    func fetchBlockedUserIDs(currentUserID: String) async throws -> Set<String> {
        let snapshot = try await firestore
            .collection("users")
            .document(currentUserID)
            .collection("blocks")
            .getDocuments()
        return Set(snapshot.documents.map { $0.documentID })
    }

    // MARK: - Account Deletion

    func deleteAllPostsByUser(authorID: String) async throws {
        let allComments = try await firestore
            .collectionGroup("comments")
            .whereField("authorID", isEqualTo: authorID)
            .getDocuments()

        var commentCountByPost: [String: Int] = [:]
        for comment in allComments.documents {
            guard let postID = comment.reference.parent.parent?.documentID else { continue }
            commentCountByPost[postID, default: 0] += 1
        }

        for comment in allComments.documents {
            try await comment.reference.delete()
        }

        for (postID, count) in commentCountByPost {
            try? await firestore
                .collection("posts")
                .document(postID)
                .updateData(["commentCount": FieldValue.increment(Int64(-count))])
        }

        let snapshot = try await firestore
            .collection("posts")
            .whereField("authorID", isEqualTo: authorID)
            .getDocuments()

        for document in snapshot.documents {
            let imageURLs = document.data()["imageURLs"] as? [String] ?? []
            let commentsSnapshot = try await document.reference.collection("comments").getDocuments()
            for comment in commentsSnapshot.documents { try await comment.reference.delete() }
            let likesSnapshot = try await document.reference.collection("likes").getDocuments()
            for like in likesSnapshot.documents { try await like.reference.delete() }
            try await document.reference.delete()
            let storageService = await MainActor.run { FirebaseStorageService() }
            await storageService.delete(urls: imageURLs)
        }

        let blocksSnapshot = try await firestore
            .collection("users")
            .document(authorID)
            .collection("blocks")
            .getDocuments()
        for block in blocksSnapshot.documents { try await block.reference.delete() }
    }

    // MARK: - Notification

    func createNotification(
        targetUserID: String,
        type: String,
        senderName: String,
        postID: String,
        body: String
    ) async throws {
        try await firestore
            .collection("users")
            .document(targetUserID)
            .collection("notifications")
            .document(UUID().uuidString)
            .setData([
                "type": type,
                "senderName": senderName,
                "postID": postID,
                "body": body,
                "receivedAt": Timestamp(date: Date()),
                "isRead": false
            ])
    }
}
