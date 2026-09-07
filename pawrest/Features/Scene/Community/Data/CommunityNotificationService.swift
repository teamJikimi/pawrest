//
//  CommunityNotificationService.swift
//  pawrest
//
//  Created by Moon AYoung on 9/4/26.
//

import Foundation

final class CommunityNotificationService {
    static let shared = CommunityNotificationService()
    private init() {}
    
    private var isEnabled: Bool {
        UserDefaults.standard.object(forKey: "communityReactionEnabled") as? Bool ?? true
    }
    
    // MARK: - 댓글/대댓글 알림
    
    func handleNewComment(
        targetUserID: String,
        commentAuthorID: String,
        commentAuthorName: String,
        commentContent: String,
        postID: String
    ) {
        guard isEnabled else { return }
        guard targetUserID != commentAuthorID else { return }
        
        let preview = commentContent.count > 54
        ? String(commentContent.prefix(54)) + "…"
        : commentContent
        let body = "새로운 댓글이 달렸습니다:\n\(preview)"
        
        Task {
            try? await CommunityFirestoreService().createNotification(
                targetUserID: targetUserID,
                type: "comment",
                senderName: commentAuthorName,
                postID: postID,
                body: body
            )
        }
    }
    
    // MARK: - 좋아요 알림
    
    func handleNewLike(
        postAuthorID: String,
        likedByUserID: String,
        likedByUserName: String,
        postID: String
    ) {
        guard isEnabled else { return }
        guard postAuthorID != likedByUserID else { return }
        
        let body = "\(likedByUserName)님이 좋아요를 눌렀습니다."
        
        Task {
            try? await CommunityFirestoreService().createNotification(
                targetUserID: postAuthorID,
                type: "like",
                senderName: likedByUserName,
                postID: postID,
                body: body
            )
        }
    }
}
