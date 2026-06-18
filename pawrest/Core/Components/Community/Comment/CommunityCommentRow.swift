//
//  CommunityCommentRow.swift
//  pawrest
//
//  Created by Moon AYoung on 5/28/26.
//

import SwiftUI

struct CommunityCommentRow: View {
    
    //MARK: - Action
    
    enum Action: Equatable {
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
    var opensMenuUpward: Bool = false
    
    let onAction: (Action) -> Void
    
    @State private var isMenuOpen = false
    
    //MARK: - Body
    
    var body: some View {
        Group {
            if isReply { replyLayout }
            else { topLevelLayout }
        }
        .zIndex(isMenuOpen ? 1000 : 0)
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
                .padding(.top, 8)
        }
    }
    
    var replyLayout: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(.iconReply)
    
            VStack(alignment: .leading, spacing: 0){
                authorHeader
                commentContent
                
                replyMoreButton
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, 8)
            }
            .padding(16)
            .background {
                RoundedCorner(radius: 8, corners: .allCorners)
                    .fill(.gray10)
            }
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
            
            moreMenuButton
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background {
            RoundedCorner(radius: 8, corners: .allCorners)
                .fill(.gray10)
        }
    }
    
    var replyMoreButton: some View {
        moreMenuButton
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
    }
    
    @ViewBuilder
    var moreMenuButton: some View {
        if isMyComment {
            EditMenuButton (
                icon: .iconReplyMore,
                size: .comment,
                showsEdit: false,
                opensUpward: opensMenuUpward,
                onEdit: { onAction(.editTapped) },
                onDelete: { onAction(.deleteTapped) },
                onMenuVisibilityChanged: { isMenuOpen = $0 }
            )
        } else {
            ReportMenuButton (
                icon: .iconReplyMore,
                size :.comment,
                opensUpward: opensMenuUpward,
                onBoardSettings: { onAction(.reportBoardSettings)},
                onReportAbuse: { onAction(.reportAbuse)},
                onReportSpam: { onAction(.reportSpam)},
                onBlock: { onAction(.blockTapped)},
                onMenuVisibilityChanged: { isMenuOpen = $0 }
            )
        }
    }
}
