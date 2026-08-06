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
    
    let currentUserID: String
    
    var replyingToCommentID: UUID? = nil
    
    var shouldDismiss: Bool = false
    
    var isDeleted: Bool = false
    var isEditPresented: Bool = false
    
    var inputPlaceholder: String {
        replyingToCommentID == nil ? "댓글을 입력하세요." : "대댓글을 입력하세요."
    }
    
    var isOwnPost: Bool {
        post.author.id == currentUserID
    }
    
    init(post: Post, currentUserID: String) {
        self.post = post
        self.currentUserID = currentUserID
        self.navigationBar = NavigationBarState(
            title: "커뮤니티",
            leftButton: .back,
            rightButton: post.author.id == currentUserID
                ? .editMenu
                : .reportMenu
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
    
    case editDismissed
    case postEdited(title: String, content: String, imageURLs: [String])
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
                state.isEditPresented = true
                return .none
                
            case .navigationBar(.deleteTapped):
                state.isDeleted = true
                state.shouldDismiss = true
                return .none
                
            case .navigationBar(.reportBoardSettings):
                return .none
                
            case .navigationBar(.reportAbuse):
                return .none
                
            case .navigationBar(.reportSpam):
                return .none
                
            case .navigationBar(.blockTapped):
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
                return .none
                
            case .commentAction(_, .editTapped):
                return .none
                
            case .commentAction(let id, .deleteTapped):
                if let idx = state.post.comments.firstIndex(where: { $0.id == id }) {
                    state.post.comments.remove(at: idx)
                    return .none
                }
                for parentIdx in state.post.comments.indices {
                    if let replyIdx = state.post.comments[parentIdx].replies.firstIndex(where: { $0.id == id }) {
                        state.post.comments[parentIdx].replies.remove(at: replyIdx)
                        return .none
                    }
                }
                return .none
                
            case .commentAction(_, .reportBoardSettings):
                return .none
                
            case .commentAction(_, .reportAbuse):
                return .none
                
            case .commentAction(_, .reportSpam):
                return .none
                
            case .commentAction(_, .blockTapped):
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
                } else {
                    state.post.comments.append(newComment)
                }
                
                state.text = ""
                state.replyingToCommentID = nil
                return .none
                
            case .outsideTapped:
                state.replyingToCommentID = nil
                return .none
                
            case .editDismissed:
                state.isEditPresented = false
                return .none

            case .postEdited(let title, let content, let imageURLs):
                state.post.title = title
                state.post.content = content
                state.post.imageURLs = imageURLs
                state.isEditPresented = false
                return .none
            }
        }
    }
}
