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
    var authorName: String = "나"

    var replyingToCommentID: UUID? = nil
    var authorProfileImageURL: String? = nil
    
    var shouldDismiss: Bool = false
    var isDeleted: Bool = false

    @Presents var write: CommunityWriteState?

    var inputPlaceholder: String {
        replyingToCommentID == nil ? "댓글을 입력하세요." : "대댓글을 입력하세요."
    }

    var isOwnPost: Bool {
        post.author.id == currentUserID
    }

    init(post: Post, currentUserID: String, authorName: String = "나", authorProfileImageURL: String? = nil) {
        self.post = post
        self.currentUserID = currentUserID
        self.authorName = authorName
        self.authorProfileImageURL = authorProfileImageURL
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
    case write(PresentationAction<CommunityWriteAction>)

    case onAppear
    case commentsLoaded([Comment])

    case likeTapped
    case commentAction(commentID: UUID, action: CommunityCommentRow.Action)

    case textChanged(String)
    case sendTapped

    case outsideTapped

    case delegate(Delegate)

    @CasePathable
    enum Delegate: Equatable {
        case postDeleted(postID: String)
        case postUpdated(Post)
        case userBlocked(userID: String)
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

            case .navigationBar(.leftButtonTapped):
                state.shouldDismiss = true
                return .cancel(id: "communityDetail.observeComments")

            case .navigationBar(.editTapped):
                state.write = CommunityWriteState(editingPost: state.post)
                return .none

            case .navigationBar(.deleteTapped):
                let postID = state.post.id
                let imageURLs = state.post.imageURLs
                state.isDeleted = true
                state.shouldDismiss = true
                return .run { [communityRepository] send in
                    try? await communityRepository.deletePost(postID, imageURLs)
                    await send(.delegate(.postDeleted(postID: postID)))
                }
                .concatenate(with: .cancel(id: "communityDetail.observeComments"))

            case .navigationBar(.reportBoardSettings),
                 .navigationBar(.reportAbuse),
                 .navigationBar(.reportSpam),
                 .navigationBar(.blockTapped),
                 .navigationBar:
                return .none

            // MARK: Write (edit)

            case .write(.presented(.delegate(.save(let title, let content, let images)))):
                let post = state.post
                let payloads = images.compactMap { $0.uploadPayload }
                state.write = nil
                return .run { [communityRepository] send in
                    if let updated = try? await communityRepository.updatePost(
                        Post(
                            id: post.id,
                            author: post.author,
                            title: title,
                            content: content,
                            createdAt: post.createdAt,
                            imageURLs: post.imageURLs,
                            likeCount: post.likeCount,
                            isLiked: post.isLiked,
                            comments: post.comments
                        ),
                        payloads
                    ) {
                        await send(.delegate(.postUpdated(updated)))
                    }
                }

            case .write:
                return .none

            // MARK: Comments

            case .onAppear:
                let postID = state.post.id
                return .run { [communityRepository] send in
                    let stream = communityRepository.observeComments(postID)
                    for await dtos in stream {
                        let comments = await MainActor.run { buildCommentTree(from: dtos) }
                        await send(.commentsLoaded(comments))
                    }
                }
                .cancellable(id: "communityDetail.observeComments", cancelInFlight: true)

            case .commentsLoaded(let comments):
                state.post.comments = comments
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
                if let idx = state.post.comments.firstIndex(where: { $0.id == id }) {
                    state.post.comments.remove(at: idx)
                } else {
                    for parentIdx in state.post.comments.indices {
                        if let replyIdx = state.post.comments[parentIdx].replies.firstIndex(where: { $0.id == id }) {
                            state.post.comments[parentIdx].replies.remove(at: replyIdx)
                            break
                        }
                    }
                }
                return .run { [communityRepository] _ in
                    try? await communityRepository.deleteComment(postID, id)
                }

            case .commentAction(_, .reportBoardSettings),
                 .commentAction(_, .reportAbuse),
                 .commentAction(_, .reportSpam),
                 .commentAction(_, .blockTapped):
                return .none

            // MARK: Input bar

            case .textChanged(let text):
                state.text = text
                return .none

            case .sendTapped:
                let trimmed = state.text.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return .none }
                state.text = ""
                let replyingTo = state.replyingToCommentID
                state.replyingToCommentID = nil
                let postID = state.post.id
                let authorID = state.currentUserID
                let authorName = state.authorName
                let authorProfileImageURL = state.authorProfileImageURL
                return .run { [communityRepository] _ in
                    let start = Date()
                    print("[Comment] createComment 시작")
                    do {
                        _ = try await communityRepository.createComment(
                            postID, authorID, authorName, authorProfileImageURL, trimmed, replyingTo
                        )
                        let elapsed = Date().timeIntervalSince(start)
                        print("[Comment] createComment 성공 - \(String(format: "%.2f", elapsed))초")
                    } catch {
                        let elapsed = Date().timeIntervalSince(start)
                        print("[Comment] createComment 실패 - \(elapsed)초 - \(error)")
                    }
                }

            case .outsideTapped:
                state.replyingToCommentID = nil
                return .none

            case .delegate:
                return .none
            }
        }
        .ifLet(\.$write, action: \.write) {
            CommunityWriteReducer()
        }
    }
}

// MARK: - Comment tree builder

@MainActor
private func buildCommentTree(from dtos: [CommunityCommentDTO]) -> [Comment] {
    var parents: [Comment] = []
    var replyMap: [UUID: [Comment]] = [:]

    for dto in dtos {
        let author = Author(id: dto.authorID, name: dto.authorName, profileImageURL: dto.authorProfileImageURL)
        let comment = Comment(id: dto.id, content: dto.content, author: author, createdAt: dto.createdAt)
        if let parentID = dto.parentCommentID {
            replyMap[parentID, default: []].append(comment)
        } else {
            parents.append(comment)
        }
    }

    return parents.map { parent in
        var p = parent
        p.replies = replyMap[parent.id] ?? []
        return p
    }
}
