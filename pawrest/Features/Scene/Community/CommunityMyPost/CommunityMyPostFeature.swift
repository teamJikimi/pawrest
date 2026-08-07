//
//  CommunityMyPostFeature.swift
//  pawrest
//
//  Created by Moon AYoung on 6/4/26.
//
import ComposableArchitecture
import Foundation

enum MyPostTab: String, CaseIterable, SegmentItem {
    case myPosts = "내가 쓴 글"
    case likedPosts = "공감한 글"
    case commentedPosts = "댓글 단 글"
    
    var title: String { rawValue }
}

@ObservableState
struct CommunityMyPostState: Equatable {
    var navigationBar = NavigationBarState(
        title: "나의 글 관리",
        leftButton: .back,
        rightButton: .none
    )
    
    var selectedTab: MyPostTab = .myPosts
    var posts: [Post]
    let currentUserID: String
    let authorName: String
    
    var shouldDismiss: Bool = false
    
    var filteredPosts: [Post] {
        let filtered: [Post]
        
        switch selectedTab {
        case .myPosts:
            filtered = posts.filter { $0.author.id == currentUserID }
        case .likedPosts:
            filtered = posts.filter { $0.isLiked }
        case .commentedPosts:
            filtered = posts.filter { post in
                post.comments.contains { $0.author.id == currentUserID } ||
                post.comments.flatMap(\.replies).contains { $0.author.id == currentUserID }
            }
        }
        
        return filtered.sorted { $0.createdAt > $1.createdAt }
    }
    
    init(
        currentUserID: String,
        posts: [Post],
        authorName: String
    ) {
        self.currentUserID = currentUserID
        self.posts = posts
        self.authorName = authorName
    }
}

// MARK: - Action

@CasePathable
enum CommunityMyPostAction: Equatable {
    case navigationBar(NavigationBarAction)
    case tabChanged(MyPostTab)
    
    case likeTapped(postID: String)
    case likeResponse(postID: String, previousIsLiked: Bool, success: Bool)
    
    case postUpdatedFromDetail(post: Post)
    case postDeleted(String)
}

// MARK: - Reducer

struct CommunityMyPostReducer: Reducer {
    
    @Dependency(\.communityRepository) var communityRepository
    
    var body: some Reducer<CommunityMyPostState, CommunityMyPostAction> {
        Scope(state: \.navigationBar, action: \.navigationBar) {
            NavigationBarReducer()
        }
        
        Reduce { state, action in
            switch action {
            case .navigationBar(.leftButtonTapped):
                state.shouldDismiss = true
                return .none
                
            case .navigationBar:
                return .none
                
            case .tabChanged(let tab):
                state.selectedTab = tab
                return .none
                
            case .likeTapped(let postID):
                guard let idx = state.posts.firstIndex(where: { $0.id == postID })
                else { return .none }
                
                let previousIsLiked = state.posts[idx].isLiked
                let userID = state.currentUserID
                
                state.posts[idx].isLiked.toggle()
                state.posts[idx].likeCount += state.posts[idx].isLiked ? 1 : -1
                
                return .run { send in
                    do {
                        try await communityRepository.toggleLike(
                            postID,
                            userID,
                            previousIsLiked
                        )
                        await send(.likeResponse(
                            postID: postID,
                            previousIsLiked: previousIsLiked,
                            success: true
                        ))
                    } catch {
                        await send(.likeResponse(
                            postID: postID,
                            previousIsLiked: previousIsLiked,
                            success: false
                        ))
                    }
                }

            case .likeResponse(let postID, let previousIsLiked, let success):
                guard !success else { return .none }
                
                guard let idx = state.posts.firstIndex(where: { $0.id == postID })
                else { return .none }
                
                state.posts[idx].isLiked = previousIsLiked
                state.posts[idx].likeCount += previousIsLiked ? 1 : -1
                return .none
                
            case .postUpdatedFromDetail(let post):
                if let idx = state.posts.firstIndex(where: { $0.id == post.id }) {
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
