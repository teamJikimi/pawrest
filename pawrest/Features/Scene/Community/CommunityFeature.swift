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

    @Presents var write: CommunityWriteState?
    @Presents var detail: CommunityDetailState?
    @Presents var myPost: CommunityMyPostState?

    var posts: [Post] = []
    var currentUserID: String?
    var authorName: String?

    var isLoading: Bool = false
    var hasLoadedPosts: Bool = false
    var errorMessage: String?
    
    var blockedUserIDs: Set<String> = []

    var displayedPosts: [Post] {
        let filtered: [Post]

        if text.isEmpty {
            filtered = posts.filter { !blockedUserIDs.contains($0.author.id) }
        } else {
            filtered = posts.filter {
                !blockedUserIDs.contains($0.author.id)
                && ($0.title.localizedCaseInsensitiveContains(text)
                    || $0.content.localizedCaseInsensitiveContains(text))
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
    case refreshPulled
    case userProfileLoaded(String?)
    case postsResponse(TaskResult<[Post]>)
    case postCreationResponse(TaskResult<Post>)

    case navigationBar(NavigationBarAction)

    case textChanged(String)
    case sortMenuOpenChanged(Bool)
    case sortModeSelected(SortMode)
    case outsideTapped

    case postTapped(postID: String)
    case likeTapped(postID: String)

    case likeResponse(
        postID: String,
        previousIsLiked: Bool,
        success: Bool
    )

    case write(PresentationAction<CommunityWriteAction>)
    case detail(PresentationAction<CommunityDetailAction>)
    case myPost(PresentationAction<CommunityMyPostAction>)
    
    case blockedUserIDsLoaded(Set<String>)
    case refreshBlockedUsers
}

// MARK: - Reducer

struct CommunityReducer: Reducer {
    @Dependency(\.communityRepository) var communityRepository
    @Dependency(\.authSessionClient) var authSessionClient

    var body: some Reducer<CommunityState, CommunityAction> {
        Scope(
            state: \.navigationBar,
            action: \.navigationBar
        ) {
            NavigationBarReducer()
        }

        Reduce { state, action in
            switch action {

            // MARK: User Profile

            case .userProfileLoaded(let nickname):
                let trimmedNickname = nickname?
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                state.authorName = trimmedNickname?.isEmpty == false
                    ? trimmedNickname
                    : nil

                return .none

            // MARK: Load Posts

            case .onAppear:
                guard !state.hasLoadedPosts else { return .none }
                
                guard let currentUserID = authSessionClient.currentUserID() else {
                    state.posts = []
                    state.errorMessage = "로그인이 필요합니다."
                    return .none
                }

                state.currentUserID = currentUserID
                state.isLoading = true
                state.errorMessage = nil

                return fetchPosts(userID: currentUserID)
                
            case .refreshPulled:
                guard let currentUserID = state.currentUserID
                        ?? authSessionClient.currentUserID()
                else { return .none }
                
                state.currentUserID = currentUserID
                return fetchPosts(userID: currentUserID)

            case .postsResponse(.success(let posts)):
                state.isLoading = false
                state.hasLoadedPosts = true
                state.posts = posts
                return .none

            case .postsResponse(.failure(let error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none

            // MARK: Navigation

            case .navigationBar(.writePostTapped):
                state.write = CommunityWriteState()
                return .none

            case .navigationBar(.myPostsTapped):
                guard let currentUserID = state.currentUserID else { return .none }
                state.myPost = CommunityMyPostState(
                    currentUserID: currentUserID,
                    posts: state.posts,
                    authorName: state.authorName ?? ""
                )
                return .none
                
            case .postTapped(let postID):
                guard
                    let currentUserID = state.currentUserID,
                    let post = state.posts.first(where: { $0.id == postID })
                else { return .none }
                
                state.detail = CommunityDetailState(
                    post: post,
                    currentUserID: currentUserID,
                    authorName: state.authorName ?? ""
                )
                return .none

            case .navigationBar:
                return .none

            // MARK: Search / Sort

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

            // MARK: Like

            case .likeTapped(let postID):
                guard
                    let userID = state.currentUserID,
                    let index = state.posts.firstIndex(
                        where: { $0.id == postID }
                    )
                else {
                    return .none
                }

                let previousIsLiked = state.posts[index].isLiked

                // Optimistic UI
                state.posts[index].isLiked.toggle()
                state.posts[index].likeCount +=
                    state.posts[index].isLiked ? 1 : -1

                return .run { send in
                    do {
                        try await communityRepository.toggleLike(
                            postID,
                            userID,
                            previousIsLiked
                        )

                        await send(
                            .likeResponse(
                                postID: postID,
                                previousIsLiked: previousIsLiked,
                                success: true
                            )
                        )
                    } catch {
                        await send(
                            .likeResponse(
                                postID: postID,
                                previousIsLiked: previousIsLiked,
                                success: false
                            )
                        )
                    }
                }

            case let .likeResponse(
                postID,
                previousIsLiked,
                success
            ):
                // 성공했으면 optimistic UI 상태 그대로 유지
                guard !success else {
                    return .none
                }

                // 실패했으면 원래 상태로 rollback
                guard let index = state.posts.firstIndex(
                    where: { $0.id == postID }
                ) else {
                    return .none
                }

                state.posts[index].isLiked = previousIsLiked
                state.posts[index].likeCount +=
                    previousIsLiked ? 1 : -1

                return .none

            // MARK: Presentation

            case let .detail(.presented(.delegate(delegate))):
                state.detail = nil
                switch delegate {
                case .postDeleted(let postID):
                    state.posts.removeAll { $0.id == postID }
                case .userBlocked(let userID):
                    state.blockedUserIDs.insert(userID)
                }
                return .none
                
            case .detail(.presented):
                if let post = state.detail?.post {
                    state.posts.replace(with: post)
                }
                return .none
                
            case .detail(.dismiss):
                return .none
                
            case .myPost(.presented):
                if let myPosts = state.myPost?.posts, myPosts != state.posts {
                    state.posts = myPosts
                }
                return .none
                
            case .myPost(.dismiss):
                return .send(.refreshBlockedUsers)

            // MARK: Create Post

            case let .write(.presented(.delegate(.save(title, content, images)))):
                state.write = nil
                
                guard let currentUserID = state.currentUserID else {
                    state.errorMessage = "로그인이 필요합니다."
                    return .none
                }
                
                guard let authorName = state.authorName else {
                    state.errorMessage = "프로필 닉네임을 찾을 수 없습니다."
                    return .none
                }
                
                let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
                
                guard !trimmedTitle.isEmpty, !trimmedContent.isEmpty else {
                    state.errorMessage = "제목과 내용을 입력해주세요."
                    return .none
                }
                
                let imageDatas = images.compactMap { item -> Data? in
                    guard case .local(let image) = item.source else { return nil }
                    return image.resizedJPEGData()
                }
                let postID = UUID().uuidString
                
                let optimisticPost = Post(
                    id: postID,
                    author: Author(
                        id: currentUserID,
                        name: authorName,
                        profileImageURL: nil
                    ),
                    title: trimmedTitle,
                    content: trimmedContent,
                    createdAt: Date(),
                    imageURLs: [],
                    likeCount: 0,
                    isLiked: false,
                    comments: []
                )
                state.posts.insert(optimisticPost, at: 0)
                
                return .run { send in
                    await send(
                        .postCreationResponse(
                            TaskResult {
                                let imageURLs = try await communityRepository.uploadImages(
                                    currentUserID,
                                    postID,
                                    imageDatas
                                )
                                
                                return try await communityRepository.createPost(
                                    postID,
                                    currentUserID,
                                    authorName,
                                    trimmedTitle,
                                    trimmedContent,
                                    imageURLs
                                )
                            }
                        )
                    )
                }

            case .write:
                return .none

            case .postCreationResponse(.success(let post)):
                state.isLoading = false
                if let index = state.posts.firstIndex(where: { $0.id == post.id }) {
                    state.posts[index] = post
                }
                return .none

            case .postCreationResponse(.failure(let error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none

            case .blockedUserIDsLoaded(let ids):
                state.blockedUserIDs = ids
                return .none
                
            case .refreshBlockedUsers:
                guard let currentUserID = state.currentUserID else {
                    return .none
                }
                
                return .run { send in
                    let blockedIDs = try await communityRepository.fetchBlockedUserIDs(currentUserID)
                    await send(.blockedUserIDsLoaded(blockedIDs))
                }
                
            }
        }
        .ifLet(\.$write, action: \.write) {
            CommunityWriteReducer()
        }
        .ifLet(\.$detail, action: \.detail) {
            CommunityDetailReducer()
        }
        .ifLet(\.$myPost, action: \.myPost) {
            CommunityMyPostReducer()
        }
    }
}

// MARK: - Effects

private extension CommunityReducer {
    
    func fetchPosts(userID: String) -> Effect<CommunityAction> {
        .run { send in
            async let postsResult = communityRepository.fetchPosts(userID)
            async let blockedResult = communityRepository.fetchBlockedUserIDs(userID)
            
            do {
                let posts = try await postsResult
                let blockedIDs = try await blockedResult
                await send(.postsResponse(.success(posts)))
                await send(.blockedUserIDsLoaded(blockedIDs))
            } catch {
                await send(.postsResponse(.failure(error)))
            }
        }
    }
}
