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
    
    var displayName: String { rawValue }
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
    
    var posts: [Post]
    
    var currentUserID: UUID
    
    var displayedPosts: [Post] {
        let filtered: [Post]
        if text.isEmpty {
            filtered = posts
        } else {
            filtered = posts.filter {
                $0.title.localizedCaseInsensitiveContains(text) || $0.content.localizedCaseInsensitiveContains(text)
            }
        }
        
        switch sortMode {
        case .recent:
            return filtered.sorted { $0.createdAt > $1.createdAt }
        case .popular:
            return filtered.sorted { $0.likeCount > $1.likeCount }
        }
    }
    
    //원래 코드
//    init(currentUserID: UUID = UUID(), posts: [Post] = []) {
//        self.currentUserID = currentUserID
//        self.posts = posts
//    }
    
    //CommunityModel 더미 연결용
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
enum CommunityAction: Equatable {
    case navigationBar(NavigationBarAction)
    
    case textChanged(String)
    case sortMenuOpenChanged(Bool)
    case sortModeSelected(SortMode)
    case outsideTapped
    
    case likeTapped(postID: UUID)
    
    case myPostDismissed
}

// MARK: - Reducer

struct CommunityReducer: Reducer {
    var body: some Reducer<CommunityState, CommunityAction> {
        Scope(state: \.navigationBar, action: \.navigationBar) {
            NavigationBarReducer()
        }
        
        Reduce { state, action in
            switch action {
            case .navigationBar(.writePostTapped):
                print("글 쓰기")
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
                guard let idx = state.posts.firstIndex(where: { $0.id == postID })
                else { return .none }
                
                state.posts[idx].isLiked.toggle()
                state.posts[idx].likeCount += state.posts[idx].isLiked ? 1 : -1
                return .none
                
            case .myPostDismissed:
                state.isMyPostPresented = false
                return .none
            }
        }
    }
}
