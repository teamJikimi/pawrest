//
//  CommunityCommentRow.swift
//  pawrest
//
//  Created by Moon AYoung on 5/28/26.
//

import SwiftUI

struct CommunityCommentRow: View {
    
    //MARK: - Properties
    
    let comment: Comment
    var isReply: Bool = false
    var isMyComment: Bool = false
    var showsDivider: Bool = true
    
    var onReplyTapped: () -> Void = {}
    var onEditTapped: () -> Void = {}
    var onDeleteTapped: () -> Void = {}
    var onReportTapped: () -> Void = {}
    var onReportAbuse: () -> Void = {}
    var onReportSpam: () -> Void = {}
    var onBlockTapped: () -> Void = {}
    
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
                .padding(.top, 8)
            
            actionButtons
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.top, 8)
            
            if showsDivider {
                Rectangle()
                    .fill(.gray20)
                    .frame(height: 1)
                    .padding(.top, 20)
            }
        }
        .padding(.vertical, 20)
    }
    
    var replyLayout: some View {
        HStack(alignment: .top, spacing: 12) {
            replyConnector
                .padding(.top, 16)
            
            VStack(alignment: .leading, spacing: 8){
                replyAuthorHeader
                commentContent
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.gray10)
            
            .cornerRadius(10, corners: .allCorners)
        }
    }
}

//MARK: - Sub views

private extension CommunityCommentRow {
    
    var authorHeader: some View {
        CommunityAuthorHeader (author: comment.author, date: comment.createdAt)
    }
    
    var replyAuthorHeader: some View {
        CommunityAuthorHeader(author: comment.author, date: comment.createdAt, profileSize: 25)
    }
    
    var commentContent: some View {
        Text(comment.content)
            .typography(.body2R2)
            .foregroundColor(.gray80)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var replyConnector: some View {
        Image(.iconReply)
    }
    
}

//MARK: - Action Buttons

private extension CommunityCommentRow {
    
    var actionButtons: some View {
        HStack(spacing: 0){
            replyButton
            
            Spacer()
                .frame(width: 6)
            
            actionDivider
            
            Spacer()
                .frame(width: 4)
            
            menuButton
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
    }
    
    var replyButton: some View {
        Button(action: onReplyTapped) {
            Image(.iconReplyFill)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
        }
        .buttonStyle(.plain)
    }
    
    var actionDivider: some View {
        Rectangle()
            .fill(.gray20)
            .frame(width: 1, height: 6)
    }

    var menuButton: some View {
        Group {
            if isMyComment {
                EditMenuButton(
                    icon: .iconReplyMore,
                    onEdit: onEditTapped,
                    onDelete: onDeleteTapped
                )
            } else {
                ReportMenuButton(
                    icon: .iconReplyMore,
                    onBoardSettings: onReportTapped,
                    onReportAbuse: onReportAbuse,
                    onReportSpam: onReportSpam,
                    onBlock: onBlockTapped)
            }
        }
    }

}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(alignment: .leading, spacing: 0) {
            CommunityCommentRow(
                comment: Comment(
                    content: "저희 강아지도 산책할 때 자주 멈춰요. 냄새 맡는 시간이 강아지한테는 중요한 활동이라고 하더라고요!",
                    author: Author(
                        name: "초코 보호자",
                        profileImageURL: nil
                    ),
                    createdAt: Date()
                ),
                isReply: false,
                isMyComment: false,
                showsDivider: true,
                onReplyTapped: {
                    print("답글 달기")
                },
                onReportTapped: {
                    print("게시판 성격에 부적절함")
                },
                onReportAbuse: {
                    print("욕설/비하 신고")
                },
                onReportSpam: {
                    print("낚시/도배/스팸 신고")
                },
                onBlockTapped: {
                    print("차단하기")
                }
            )
            
            CommunityCommentRow(
                comment: Comment(
                    content: "저도 비슷한 경험이 있어요. 산책 시간을 조금 더 여유 있게 잡으니까 훨씬 좋아졌어요.",
                    author: Author(
                        name: "몽이 보호자",
                        profileImageURL: nil
                    ),
                    createdAt: Date()
                ),
                isReply: false,
                isMyComment: true,
                showsDivider: true,
                onReplyTapped: {
                    print("답글 달기")
                },
                onEditTapped: {
                    print("수정하기")
                },
                onDeleteTapped: {
                    print("삭제하기")
                }
            )
            
            CommunityCommentRow(
                comment: Comment(
                    content: "맞아요! 억지로 끌고 가기보다는 기다려주는 게 좋다고 들었어요.",
                    author: Author(
                        name: "나비 집사",
                        profileImageURL: nil
                    ),
                    createdAt: Date()
                ),
                isReply: true,
                isMyComment: false
            )
            .padding(.top, 12)
            
            CommunityCommentRow(
                comment: Comment(
                    content: "긴 댓글 테스트입니다. 산책 중에 멈추는 행동이 단순히 고집이 아니라 주변 냄새를 맡고 정보를 탐색하는 자연스러운 행동일 수 있다고 해서, 요즘은 조금 기다려주면서 산책하고 있어요. 예전보다 강아지도 산책을 더 편하게 즐기는 것 같아요.",
                    author: Author(
                        name: "구름 보호자",
                        profileImageURL: nil
                    ),
                    createdAt: Date()
                ),
                isReply: false,
                isMyComment: false,
                showsDivider: true
            )
            
            CommunityCommentRow(
                comment: Comment(
                    content: "마지막 댓글이라 divider가 없는 상태입니다.",
                    author: Author(
                        name: "해피 보호자",
                        profileImageURL: nil
                    ),
                    createdAt: Date()
                ),
                isReply: false,
                isMyComment: true,
                showsDivider: false
            )
        }
        .padding(.horizontal, 20)
    }
    .background(.gray0)
}
