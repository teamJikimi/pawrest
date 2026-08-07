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
    var errorMessage: String?
    
    var isEditPresented: Bool = false
    
    var inputPlaceholder: String {
        replyingToCommentID == nil
            ? "댓글을 입력하세요."
            : "대댓글을 입력하세요."
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
    case commentAction(
        commentID: UUID,
        action: CommunityCommentRow.Action
    )
    
    case textChanged(String)
    case sendTapped
    
    case outsideTapped
    
    case editDismissed
    
    case postEdited(
        title: String,
        content: String,
        imageDatas: [Data]
    )
    
    case commentCreationResponse(
        parentCommentID: UUID?,
        TaskResult<Comment>
    )
    
    case commentDeletionResponse(
        TaskResult<UUID>
    )
    
    case postDeletionResponse(TaskResult<String>)
    case postUpdateResponse(TaskResult<Post>)
}

// MARK: - Reducer

struct CommunityDetailReducer: Reducer {
    
    @Dependency(\.communityRepository)
    var communityRepository
    
    var body: some Reducer<
        CommunityDetailState,
        CommunityDetailAction
    > {
        Scope(
            state: \.navigationBar,
            action: \.navigationBar
        ) {
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
                let postID = state.post.id
                
                return .run { send in
                    await send(
                        .postDeletionResponse(
                            TaskResult {
                                try await communityRepository
                                    .deletePost(postID)
                                
                                return postID
                            }
                        )
                    )
                }
                
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
                let postID = state.post.id
                
                return .run { send in
                    await send(
                        .commentDeletionResponse(
                            TaskResult {
                                try await communityRepository
                                    .deleteComment(
                                        postID,
                                        id
                                    )
                                
                                return id
                            }
                        )
                    )
                }
                
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
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                
                guard !trimmed.isEmpty else {
                    return .none
                }
                
                let postID = state.post.id
                let currentUserID = state.currentUserID
                let parentCommentID = state.replyingToCommentID
                
                state.text = ""
                state.replyingToCommentID = nil
                
                return .run { send in
                    await send(
                        .commentCreationResponse(
                            parentCommentID: parentCommentID,
                            TaskResult {
                                try await communityRepository
                                    .createComment(
                                        postID,
                                        currentUserID,
                                        "나",
                                        trimmed,
                                        parentCommentID
                                    )
                            }
                        )
                    )
                }
                
            case .outsideTapped:
                state.replyingToCommentID = nil
                return .none
                
            // MARK: Edit
                
            case .editDismissed:
                state.isEditPresented = false
                return .none
                
            case .postEdited(let title, let content, let imageDatas):
                let trimmedTitle = title
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                let trimmedContent = content
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                guard !trimmedTitle.isEmpty, !trimmedContent.isEmpty else {
                    state.errorMessage = "제목과 내용을 입력해주세요."
                    return .none
                }
                
                var updatedPost = state.post
                updatedPost.title = trimmedTitle
                updatedPost.content = trimmedContent
                
                return .run { send in
                    await send(
                        .postUpdateResponse(
                            TaskResult {
                                try await communityRepository
                                    .updatePost(updatedPost, imageDatas)
                            }
                        )
                    )
                }
                
            // MARK: Comment Creation Response
                
            case let .commentCreationResponse(
                parentCommentID,
                .success(comment)
            ):
                if let parentCommentID,
                   let parentIndex =
                    state.post.comments.firstIndex(
                        where: {
                            $0.id == parentCommentID
                        }
                    ) {
                    
                    state.post
                        .comments[parentIndex]
                        .replies
                        .append(comment)
                    
                } else {
                    state.post.comments.append(comment)
                }
                
                return .none
                
            case .commentCreationResponse(
                _,
                .failure(let error)
            ):
                state.errorMessage =
                    error.localizedDescription
                return .none
                
            // MARK: Comment Deletion Response
                
            case .commentDeletionResponse(
                .success(let commentID)
            ):
                // 일반 댓글 삭제
                if let index =
                    state.post.comments.firstIndex(
                        where: {
                            $0.id == commentID
                        }
                    ) {
                    
                    state.post.comments.remove(
                        at: index
                    )
                    
                    return .none
                }
                
                // 대댓글 삭제
                for parentIndex
                    in state.post.comments.indices {
                    
                    if let replyIndex =
                        state.post
                            .comments[parentIndex]
                            .replies
                            .firstIndex(
                                where: {
                                    $0.id == commentID
                                }
                            ) {
                        
                        state.post
                            .comments[parentIndex]
                            .replies
                            .remove(
                                at: replyIndex
                            )
                        
                        break
                    }
                }
                
                return .none
                
            case .commentDeletionResponse(
                .failure(let error)
            ):
                state.errorMessage =
                    error.localizedDescription
                return .none
                
            // MARK: Post Deletion Response
                
            case .postDeletionResponse(.success):
                state.isDeleted = true
                state.shouldDismiss = true
                return .none
                
            case .postDeletionResponse(
                .failure(let error)
            ):
                state.errorMessage =
                    error.localizedDescription
                return .none
                
            // MARK: Post Update Response
                
            case .postUpdateResponse(
                .success(let updatedPost)
            ):
                state.post = updatedPost
                state.isEditPresented = false
                return .none
                
            case .postUpdateResponse(
                .failure(let error)
            ):
                state.errorMessage =
                    error.localizedDescription
                return .none
            }
        }
    }
}
