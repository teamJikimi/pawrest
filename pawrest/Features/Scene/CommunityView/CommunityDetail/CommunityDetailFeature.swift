//
//  CommunityDetailFeature.swift
//  pawrest
//
//  Created by Moon AYoung on 6/1/26.
//

import Foundation
import ComposableArchitecture

// MARK: - State

@ObservableState
struct CommunityDetailState: Equatable {
    var post: Post
    var text: String = ""
    var navigationBar: NavigationBarState
    
    let currentUserID: UUID
    
    var replyingToCommentID: UUID? = nil
    
    var shouldDismiss: Bool = false
    
    var inputPlaceholder: String {
        replyingToCommentID == nil ? "댓글을 입력하세요." : "대댓글을 입력하세요."
    }
    
    var isOwnPost: Bool {
        post.author.id == currentUserID
    }
    
    init(post: Post, currentUserID: UUID) {
        self.post = post
        self.currentUserID = currentUserID
        self.navigationBar = NavigationBarState(
            title: "커뮤니티",
            leftButton: .back,
            rightButton: post.author.id == currentUserID ? .editMenu : .reportMenu
        )
    }
}

// MARK: - Action

@CasePathable
enum CommunityDetailAction: Equatable {
    case navigationBar(NavigationBarAction)
    
    case likeTapped
    case commentAction(commentID: UUID, action: CommunityCommentRow.Action)
    
    case textChanged(String)
    case sendTapped
    
    case outsideTapped
}

// MARK: - Reducer

struct CommunityDetailReducer: Reducer {
    var body: some Reducer<CommunityDetailState, CommunityDetailAction> {
        Scope(state: \.navigationBar, action: \.navigationBar) {
            NavigationBarReducer()
        }
        
        Reduce { state, action in
            switch action {
                
            // MARK: NavigationBar
                
            case .navigationBar(.leftButtonTapped):
                state.shouldDismiss = true
                return .none
                
            case .navigationBar(.editTapped):
                print("게시글 수정")
                return .none
                
            case .navigationBar(.deleteTapped):
                print("게시글 삭제")
                return .none
                
            case .navigationBar(.reportBoardSettings):
                print("게시글 신고 - 게시판 부적절")
                return .none
                
            case .navigationBar(.reportAbuse):
                print("게시글 신고 - 욕설/비하")
                return .none
                
            case .navigationBar(.reportSpam):
                print("게시글 신고 - 낚시/도배/스팸")
                return .none
                
            case .navigationBar(.blockTapped):
                print("게시글 작성자 차단")
                return .none
                
            case .navigationBar:
                return .none
                
            // MARK: Post
                
            case .likeTapped:
                state.post.isLiked.toggle()
                state.post.likeCount += state.post.isLiked ? 1 : -1
                return .none
                
            // MARK: Comment actions
                
            case .commentAction(let id, .replyTapped):
                state.replyingToCommentID = id
                print("댓글 \(id) 에 답글 작성 모드 진입")
                return .none
                
            case .commentAction(let id, .editTapped):
                print("댓글 수정 (\(id))")
                return .none
                
            case .commentAction(let id, .deleteTapped):
                print("댓글 삭제 (\(id))")
                return .none
                
            case .commentAction(let id, .reportBoardSettings):
                print("댓글 신고 - 게시판 부적절 (\(id))")
                return .none
                
            case .commentAction(let id, .reportAbuse):
                print("댓글 신고 - 욕설/비하 (\(id))")
                return .none
                
            case .commentAction(let id, .reportSpam):
                print("댓글 신고 - 낚시/도배/스팸 (\(id))")
                return .none
                
            case .commentAction(let id, .blockTapped):
                print("댓글 작성자 차단 (\(id))")
                return .none
                
            // MARK: Input bar
                
            case .textChanged(let text):
                state.text = text
                return .none
                
            case .sendTapped:
                let trimmed = state.text
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return .none }
                
                let newComment = Comment(
                    content: trimmed,
                    author: Author(id: state.currentUserID, name: "나", profileImageURL: nil),
                    createdAt: Date()
                )
                
                if let parentID = state.replyingToCommentID,
                   let parentIdx = state.post.comments.firstIndex(where: { $0.id == parentID }) {
                    state.post.comments[parentIdx].replies.append(newComment)
                    print("대댓글 추가됨 → parent: \(parentID)")
                } else {
                    state.post.comments.append(newComment)
                    print("부모 댓글 추가됨")
                }
                
                state.text = ""
                state.replyingToCommentID = nil
                return .none
                
            case .outsideTapped:
                state.replyingToCommentID = nil
                return .none
            }
        }
    }
}
