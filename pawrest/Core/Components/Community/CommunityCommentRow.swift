//
//  CommunityCommentRow.swift
//  pawrest
//
//  Created by Moon AYoung on 5/28/26.
//

import SwiftUI

struct CommunityCommentRow: View {
    
    //MARK: - Action
    
    enum Action {
        case replyTapped
        case editTapped
        case deleteTapped
        case reportBoardSettings
        case reportAbuse
        case reportSpam
        case blockTapped
    }
    
    //MARK: - Properties
    
    let comment: Comment
    var isReply: Bool = false
    var isMyComment: Bool = false
    let onAction: (Action) -> Void
    
    //MARK: - Body
    
    var body: some View {
        if isReply { replyLayout }
        else { topLevelLayout }
    }

}

//MARK: - Layouts

private extension CommunityCommentRow {
    
    var topLevelLayout : some View {
        VStack(alignment: .leading, spacing: 0){
            authorHeader
            commentContent
            
            actionButtons
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.top, 6)
                .zIndex(100)
        }
    }
    
    var replyLayout: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(.iconReply)
    
            VStack(alignment: .leading, spacing: 0){
                authorHeader
                commentContent
            }
            .padding(16)
            .background(.gray10)
            .cornerRadius(8, corners: .allCorners)
        }
    }
}

//MARK: - Sub views

private extension CommunityCommentRow {
    
    var authorHeader: some View {
        CommunityAuthorHeader(
            author: comment.author,
            date: comment.createdAt,
            profileSize: 25,
            nameStyle: .comment)
    }
    
    var commentContent: some View {
        Text(comment.content)
            .typography(.body2R2)
            .foregroundColor(.gray80)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
    }
}

//MARK: - Action Buttons

private extension CommunityCommentRow {
    
    var actionButtons: some View {
        HStack(spacing: 0){
            Button { onAction(.replyTapped) } label: {
                Image(.iconReplyFill)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
            }
            .buttonStyle(.plain)
            
            Rectangle()
                .fill(.gray20)
                .frame(width: 1, height: 6)
                .padding(.leading, 6)
                .padding(.trailing, 4)
            
            if isMyComment {
                EditMenuButton (
                    icon: .iconReplyMore,
                    size: .comment,
                    showsEdit: false,
                    onEdit: { onAction(.editTapped) },
                    onDelete: { onAction(.deleteTapped) }
                )
            } else {
                ReportMenuButton (
                    icon: .iconReplyMore,
                    size :.comment,
                    onBoardSettings: { onAction(.reportBoardSettings)},
                    onReportAbuse: { onAction(.reportAbuse)},
                    onReportSpam: { onAction(.reportSpam)},
                    onBlock: { onAction(.blockTapped)}
                )
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(.gray10)
        .cornerRadius(8, corners: .allCorners)
    }
}
