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
    let currentUserID: UUID
    
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
    
    //커뮤니티 Model 더미 연결용
    init(
        currentUserID: UUID = CommunityDummy.currentUserID,
        posts: [Post] = CommunityDummy.posts
    ) {
        self.currentUserID = currentUserID
        self.posts = posts
    }
}

// MARK: - Action

@CasePathable
enum CommunityMyPostAction: Equatable {
    case navigationBar(NavigationBarAction)
    case tabChanged(MyPostTab)
    case likeTapped(postID: UUID)
    
    case postUpdatedFromDetail(post: Post)
}

// MARK: - Reducer

struct CommunityMyPostReducer: Reducer {
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
                state.posts[idx].isLiked.toggle()
                state.posts[idx].likeCount += state.posts[idx].isLiked ? 1 : -1
                return .none
                
            case .postUpdatedFromDetail(let post):
                if let idx = state.posts.firstIndex(where: { $0.id == post.id }) {
                    state.posts[idx] = post
                }
                return .none
            }
        }
    }
}
