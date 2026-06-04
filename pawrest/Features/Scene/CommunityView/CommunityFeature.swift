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
    
    //dummy
    init(
        currentUserID: UUID = CommunityState.dummyCurrentUserID,
        posts: [Post] = CommunityState.dummyPosts
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
                print("나의 글 관리")
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
            }
        }
    }
}

//MARK: - Dummy

private extension CommunityState {
    static let dummyCurrentUserID = UUID()
    
    static let dummyOtherUserID = UUID()
    static let dummyThirdUserID = UUID()
    
    static var dummyPosts: [Post] {
        [
            Post(
                author: Author(
                    id: dummyOtherUserID,
                    name: "방울이아빠",
                    profileImageURL: nil
                ),
                title: "오늘 우리 콩이를 보냈어요",
                content: "오랜 시간 함께한 아이를 보내는 일이 이렇게 힘든 줄 몰랐어요. 같은 경험을 하신 분들이 있다면 어떻게 견디셨는지 궁금해요.",
                createdAt: Date().addingTimeInterval(-3600),
                imageURLs: [],
                likeCount: 12,
                isLiked: false,
                comments: [
                    Comment(
                        content: "저도 비슷한 경험이 있어서 마음이 아프네요.",
                        author: Author(id: dummyThirdUserID, name: "초코이모", profileImageURL: nil),
                        createdAt: Date().addingTimeInterval(-3000)
                    )
                ]
            ),
            Post(
                author: Author(
                    id: dummyThirdUserID,
                    name: "초코이모",
                    profileImageURL: nil
                ),
                title: "산책 사진 모음",
                content: "오늘 날씨가 좋아서 산책 다녀왔어요.",
                createdAt: Date().addingTimeInterval(-7200),
                imageURLs: [
                    "https://picsum.photos/seed/pawrest1/400/400"
                ],
                likeCount: 25,
                isLiked: true,
                comments: []
            ),
            Post(
                author: Author(
                    id: dummyCurrentUserID,
                    name: "나",
                    profileImageURL: nil
                ),
                title: "강아지 사료 추천 부탁드려요",
                content: "10살 노견인데 신장 수치가 안 좋아져서 신장 케어 사료를 찾고 있어요.",
                createdAt: Date().addingTimeInterval(-86400),
                imageURLs: [],
                likeCount: 3,
                isLiked: false,
                comments: []
            )
        ]
    }
}
