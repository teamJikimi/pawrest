//
//  CommunityFeature.swift
//  pawrest
//
//  Created by 소은 on 5/20/26.
//

import ComposableArchitecture
import Foundation

enum SortMode: String, CaseIterable, Equatable {
    case recent = "최신순"
    case popular = "인기순"

    var displayName: String {
        rawValue
    }
}

// MARK: - State

@ObservableState
struct CommunityState: Equatable {
    var navigationBar = NavigationBarState(
        title: "커뮤니티",
        leftButton: .none,
        rightButton: .communityAddMenu
    )

    var text: String = ""
    var sortMode: SortMode = .recent
    var isSortMenuOpen: Bool = false

    var isMyPostPresented: Bool = false
    var isWritePostPresented: Bool = false
    var isDetailPresented: Bool = false

    var posts: [Post] = []
    var currentUserID: String?
    var authorName: String?

    var isLoading: Bool = false
    var errorMessage: String?

    var displayedPosts: [Post] {
        let filtered: [Post]

        if text.isEmpty {
            filtered = posts
        } else {
            filtered = posts.filter {
                $0.title.localizedCaseInsensitiveContains(text)
                    || $0.content.localizedCaseInsensitiveContains(text)
            }
        }

        switch sortMode {
        case .recent:
            return filtered.sorted { $0.createdAt > $1.createdAt }

        case .popular:
            return filtered.sorted { $0.likeCount > $1.likeCount }
        }
    }

    init(
        currentUserID: String? = nil,
        posts: [Post] = []
    ) {
        self.currentUserID = currentUserID
        self.posts = posts
    }
}

// MARK: - Action

@CasePathable
enum CommunityAction: Equatable {
    case onAppear
    case userProfileLoaded(String?)
    case postsResponse(TaskResult<[Post]>)
    case postCreationResponse(TaskResult<Post>)

    case navigationBar(NavigationBarAction)

    case textChanged(String)
    case sortMenuOpenChanged(Bool)
    case sortModeSelected(SortMode)
    case outsideTapped

    case likeTapped(postID: String)

    case myPostDismissed
    case writePostDismissed
    case detailPresented
    case detailDismissed

    case newPostCreated(title: String, content: String, imageURLs: [String])
    case myPostsUpdated(posts: [Post])
    case postStateUpdated(Post)
    case postDeleted(String)
}

// MARK: - Reducer

struct CommunityReducer: Reducer {
    @Dependency(\.communityRepository) var communityRepository
    @Dependency(\.authSessionClient) var authSessionClient

    var body: some Reducer<CommunityState, CommunityAction> {
        Scope(state: \.navigationBar, action: \.navigationBar) {
            NavigationBarReducer()
        }

        Reduce { state, action in
            switch action {
            case .userProfileLoaded(let nickname):
                let trimmedNickname = nickname?
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                state.authorName = trimmedNickname?.isEmpty == false
                    ? trimmedNickname
                    : nil

                return .none

            case .onAppear:
                guard let currentUserID = authSessionClient.currentUserID() else {
                    state.posts = []
                    state.errorMessage = "로그인이 필요합니다."
                    return .none
                }

                state.currentUserID = currentUserID
                state.isLoading = true
                state.errorMessage = nil

                return .run { send in
                    await send(
                        .postsResponse(
                            TaskResult {
                                try await communityRepository.fetchPosts()
                            }
                        )
                    )
                }

            case .postsResponse(.success(let posts)):
                state.isLoading = false
                state.posts = posts
                return .none

            case .postsResponse(.failure(let error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none

            case .navigationBar(.writePostTapped):
                state.isWritePostPresented = true
                return .none

            case .navigationBar(.myPostsTapped):
                state.isMyPostPresented = true
                return .none

            case .navigationBar:
                return .none

            case .textChanged(let newText):
                state.text = newText
                return .none

            case .sortMenuOpenChanged(let isOpen):
                state.isSortMenuOpen = isOpen
                return .none

            case .sortModeSelected(let mode):
                state.sortMode = mode
                return .none

            case .outsideTapped:
                state.isSortMenuOpen = false
                return .none

            case .likeTapped(let postID):
                guard let idx = state.posts.firstIndex(
                    where: { $0.id == postID }
                ) else {
                    return .none
                }

                state.posts[idx].isLiked.toggle()
                state.posts[idx].likeCount += state.posts[idx].isLiked ? 1 : -1
                return .none

            case .myPostDismissed:
                state.isMyPostPresented = false
                return .none

            case .writePostDismissed:
                state.isWritePostPresented = false
                return .none

            case .detailPresented:
                state.isDetailPresented = true
                return .none

            case .detailDismissed:
                state.isDetailPresented = false
                return .none

            case .newPostCreated(let title, let content, _):
                guard let currentUserID = state.currentUserID else {
                    state.errorMessage = "로그인이 필요합니다."
                    return .none
                }

                guard let authorName = state.authorName else {
                    state.errorMessage = "프로필 닉네임을 찾을 수 없습니다."
                    return .none
                }

                let trimmedTitle = title.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                let trimmedContent = content.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

                guard !trimmedTitle.isEmpty, !trimmedContent.isEmpty else {
                    state.errorMessage = "제목과 내용을 입력해주세요."
                    return .none
                }

                return .run { send in
                    await send(
                        .postCreationResponse(
                            TaskResult { try await communityRepository.createPost( currentUserID, authorName, trimmedTitle, trimmedContent ) } )
                    )
                }

            case .postCreationResponse(.success(let post)):
                state.posts.insert(post, at: 0)
                state.isWritePostPresented = false
                return .none

            case .postCreationResponse(.failure(let error)):
                state.errorMessage = error.localizedDescription
                return .none

            case .myPostsUpdated(let posts):
                state.posts = posts
                return .none

            case .postStateUpdated(let post):
                if let idx = state.posts.firstIndex(
                    where: { $0.id == post.id }
                ) {
                    state.posts[idx] = post
                }

                return .none

            case .postDeleted(let postID):
                state.posts.removeAll { $0.id == postID }
                return .none
            }
        }
    }
}
