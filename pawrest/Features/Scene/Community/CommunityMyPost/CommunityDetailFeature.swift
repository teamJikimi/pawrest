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
    let authorName: String
    
    var replyingToCommentID: UUID? = nil
    
    var errorMessage: String?
    
    @Presents var edit: CommunityWriteState?
    
    var inputPlaceholder: String {
        replyingToCommentID == nil
            ? "댓글을 입력하세요."
            : "대댓글을 입력하세요."
    }
    
    var isOwnPost: Bool {
        post.author.id == currentUserID
    }
    
    init(post: Post, currentUserID: String, authorName: String) {
        self.post = post
        self.currentUserID = currentUserID
        self.authorName = authorName
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
    
    case onAppear
    case commentsFetched(TaskResult<[Comment]>)
    
    case textChanged(String)
    case sendTapped
    case outsideTapped
    
    case edit(PresentationAction<CommunityWriteAction>)
    
    case likeResponse(previousIsLiked: Bool, success: Bool)
    case commentCreationResponse(parentCommentID: UUID?, TaskResult<Comment>)
    case commentDeletionResponse(TaskResult<UUID>)
    case postDeletionResponse(TaskResult<String>)
    case postUpdateResponse(TaskResult<Post>)
    case reportResponse(TaskResult<Bool>)
    case blockResponse(blockedUserID: String, TaskResult<Bool>)
    
    case delegate(Delegate)
    
    @CasePathable
    enum Delegate: Equatable {
        case postDeleted(String)
        case userBlocked(String)
    }
}

// MARK: - Reducer

struct CommunityDetailReducer: Reducer {
    
    @Dependency(\.communityRepository) var communityRepository
    
    var body: some Reducer<CommunityDetailState, CommunityDetailAction> {
        Scope(state: \.navigationBar, action: \.navigationBar) {
            NavigationBarReducer()
        }
        
        Reduce { state, action in
            switch action {
                
            // MARK: NavigationBar
                
            case .navigationBar(.editTapped):
                state.edit = CommunityWriteState(editingPost: state.post)
                return .none
                
            case .navigationBar(.deleteTapped):
                let postID = state.post.id
                let imageURLs = state.post.imageURLs
                
                return .run { send in
                    await send(.postDeletionResponse(TaskResult {
                        try await communityRepository.deletePost(postID, imageURLs)
                        return postID
                    }))
                }
                
            // MARK: NavigationBar — Report / Block
                
            case .navigationBar(.reportBoardSettings):
                return reportPost(state: state, reason: "boardSettings")
                
            case .navigationBar(.reportAbuse):
                return reportPost(state: state, reason: "abuse")
                
            case .navigationBar(.reportSpam):
                return reportPost(state: state, reason: "spam")
                
            case .navigationBar(.blockTapped):
                return blockUser(
                    currentUserID: state.currentUserID,
                    targetUser: state.post.author
                )
                
            case .navigationBar:
                return .none
                
            // MARK: Like
                
            case .likeTapped:
                let postID = state.post.id
                let userID = state.currentUserID
                let previousIsLiked = state.post.isLiked
                
                state.post.isLiked.toggle()
                state.post.likeCount += state.post.isLiked ? 1 : -1
                
                return .run { send in
                    do {
                        try await communityRepository.toggleLike(
                            postID, userID, previousIsLiked
                        )
                        await send(.likeResponse(
                            previousIsLiked: previousIsLiked, success: true
                        ))
                    } catch {
                        await send(.likeResponse(
                            previousIsLiked: previousIsLiked, success: false
                        ))
                    }
                }
                
            case .likeResponse(let previousIsLiked, let success):
                guard !success else { return .none }
                state.post.isLiked = previousIsLiked
                state.post.likeCount += previousIsLiked ? 1 : -1
                return .none
                
            case .onAppear:
                let postID = state.post.id
                
                return .run { send in
                    await send(.commentsFetched(TaskResult {
                        let commentDTOs = try await communityRepository.fetchComments(postID)
                        
                        let authorIDs = Set(commentDTOs.map { $0.authorID })
                        let profileService = UserProfileRemoteService()
                        let profiles = try await profileService.fetchProfiles(
                            userIDs: Array(authorIDs)
                        )
                        
                        let topLevel = commentDTOs.filter { $0.parentCommentID == nil }
                        
                        return topLevel.map { parentDTO in
                            let replies = commentDTOs
                                .filter { $0.parentCommentID == parentDTO.id }
                                .map { $0.toDomain(profile: profiles[$0.authorID]) }
                            
                            return parentDTO.toDomain(
                                replies: replies,
                                profile: profiles[parentDTO.authorID]
                            )
                        }
                    }))
                }

            case .commentsFetched(.success(let comments)):
                state.post.comments = comments
                state.post.commentCount = comments.reduce(0) { $0 + 1 + $1.replies.count }
                return .none

            case .commentsFetched(.failure):
                return .none
                
            // MARK: Comment Actions
                
            case .commentAction(let id, .replyTapped):
                state.replyingToCommentID = id
                return .none
                
            case .commentAction(_, .editTapped):
                return .none
                
            case .commentAction(let id, .deleteTapped):
                let postID = state.post.id
                
                return .run { send in
                    await send(.commentDeletionResponse(TaskResult {
                        try await communityRepository.deleteComment(postID, id)
                        return id
                    }))
                }
                
            // MARK: Comment Actions — Report / Block
                
            case .commentAction(let commentID, .reportBoardSettings):
                return reportComment(state: state, commentID: commentID, reason: "boardSettings")
                
            case .commentAction(let commentID, .reportAbuse):
                return reportComment(state: state, commentID: commentID, reason: "abuse")
                
            case .commentAction(let commentID, .reportSpam):
                return reportComment(state: state, commentID: commentID, reason: "spam")
                
            case .commentAction(let commentID, .blockTapped):
                guard let comment = findComment(commentID: commentID, in: state.post)
                else { return .none }
                
                return blockUser(
                    currentUserID: state.currentUserID,
                    targetUser: comment.author
                )
                
            // MARK: Input Bar
                
            case .textChanged(let text):
                state.text = text
                return .none
                
            case .sendTapped:
                let trimmed = state.text.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return .none }
                
                let postID = state.post.id
                let currentUserID = state.currentUserID
                let authorName = state.authorName
                let parentCommentID = state.replyingToCommentID
                
                state.text = ""
                state.replyingToCommentID = nil
                
                return .run { send in
                    await send(.commentCreationResponse(
                        parentCommentID: parentCommentID,
                        TaskResult {
                            try await communityRepository.createComment(
                                postID, currentUserID, authorName, trimmed, parentCommentID
                            )
                        }
                    ))
                }
                
            case .outsideTapped:
                state.replyingToCommentID = nil
                return .none
                
            // MARK: Edit
                
            case let .edit(.presented(.delegate(.save(title, content, images)))):
                state.edit = nil
                
                let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
                
                guard !trimmedTitle.isEmpty, !trimmedContent.isEmpty else {
                    state.errorMessage = "제목과 내용을 입력해주세요."
                    return .none
                }
                
                var updatedPost = state.post
                updatedPost.title = trimmedTitle
                updatedPost.content = trimmedContent
                let payloads = images.compactMap(\.uploadPayload)
                
                return .run { send in
                    await send(.postUpdateResponse(TaskResult {
                        try await communityRepository.updatePost(updatedPost, payloads)
                    }))
                }
                
            case .edit:
                return .none
                
            // MARK: Responses
                
            case let .commentCreationResponse(parentCommentID, .success(comment)):
                if let parentCommentID,
                   let parentIndex = state.post.comments.firstIndex(where: { $0.id == parentCommentID }) {
                    state.post.comments[parentIndex].replies.append(comment)
                } else {
                    state.post.comments.append(comment)
                }
                state.post.commentCount += 1
                return .none
                
            case .commentCreationResponse(_, .failure(let error)):
                state.errorMessage = error.localizedDescription
                return .none
                
            case .commentDeletionResponse(.success(let commentID)):
                if let index = state.post.comments.firstIndex(where: { $0.id == commentID }) {
                    let removed = state.post.comments.remove(at: index)
                    state.post.commentCount = max(0, state.post.commentCount - 1 - removed.replies.count)
                    return .none
                }
                for parentIndex in state.post.comments.indices {
                    if let replyIndex = state.post.comments[parentIndex].replies
                        .firstIndex(where: { $0.id == commentID }) {
                        state.post.comments[parentIndex].replies.remove(at: replyIndex)
                        state.post.commentCount = max(0, state.post.commentCount - 1)
                        break
                    }
                }
                return .none
                
            case .commentDeletionResponse(.failure(let error)):
                state.errorMessage = error.localizedDescription
                return .none
                
            case .postDeletionResponse(.success(let postID)):
                return .send(.delegate(.postDeleted(postID)))
                
            case .postDeletionResponse(.failure(let error)):
                state.errorMessage = error.localizedDescription
                return .none
                
            case .postUpdateResponse(.success(let updatedPost)):
                state.post = updatedPost
                return .none
                
            case .postUpdateResponse(.failure(let error)):
                state.errorMessage = error.localizedDescription
                return .none
                
            case .reportResponse(.success):
                return .none
                
            case .reportResponse(.failure(let error)):
                state.errorMessage = error.localizedDescription
                return .none
                
            case .blockResponse(let blockedUserID, .success):
                return .send(.delegate(.userBlocked(blockedUserID)))
                
            case .blockResponse(_, .failure(let error)):
                state.errorMessage = error.localizedDescription
                return .none
                
            case .delegate:
                return .none
            }
        }
        .ifLet(\.$edit, action: \.edit) {
            CommunityWriteReducer()
        }
    }
}

// MARK: - Helpers

private extension CommunityDetailReducer {
    
    func findComment(commentID: UUID, in post: Post) -> Comment? {
        if let comment = post.comments.first(where: { $0.id == commentID }) {
            return comment
        }
        for parent in post.comments {
            if let reply = parent.replies.first(where: { $0.id == commentID }) {
                return reply
            }
        }
        return nil
    }
    
    func reportPost(
        state: CommunityDetailState,
        reason: String
    ) -> Effect<CommunityDetailAction> {
        let currentUserID = state.currentUserID
        let postID = state.post.id
        let targetAuthorID = state.post.author.id
        
        return .run { send in
            await send(.reportResponse(TaskResult {
                try await communityRepository.createReport(
                    currentUserID, "post", postID, targetAuthorID, reason
                )
                return true
            }))
        }
    }
    
    func reportComment(
        state: CommunityDetailState,
        commentID: UUID,
        reason: String
    ) -> Effect<CommunityDetailAction> {
        let currentUserID = state.currentUserID
        let targetAuthorID = findComment(commentID: commentID, in: state.post)?.author.id ?? ""
        
        return .run { send in
            await send(.reportResponse(TaskResult {
                try await communityRepository.createReport(
                    currentUserID, "comment", commentID.uuidString, targetAuthorID, reason
                )
                return true
            }))
        }
    }
    
    func blockUser(
        currentUserID: String,
        targetUser: Author
    ) -> Effect<CommunityDetailAction> {
        let blockedUserID = targetUser.id
        let blockedUserName = targetUser.name
        
        return .run { send in
            await send(.blockResponse(
                blockedUserID: blockedUserID,
                TaskResult {
                    try await communityRepository.blockUser(
                        currentUserID, blockedUserID, blockedUserName
                    )
                    return true
                }
            ))
        }
    }
}
