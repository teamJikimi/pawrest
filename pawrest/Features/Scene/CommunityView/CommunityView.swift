//
//  CommunityView.swift
//  pawrest
//
//  Created by 소은 on 5/17/26.
//

import SwiftUI
import ComposableArchitecture

struct CommunityView: View {
    @Bindable var store: StoreOf<CommunityReducer>
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        
        VStack(spacing: 0) {
            searchAndSortSection
            postsScrollView
        }
        .customNavigationBar(
            store: store.scope(
                state: \.navigationBar,
                action: \.navigationBar
            )
        )
    }
}

private extension CommunityView {
    
    var searchAndSortSection: some View {
        HStack(spacing: 6) {
            CommunitySearchBar(
                text: Binding(
                    get: { store.text },
                    set: { store.send(.textChanged($0)) }
                ),
                isFocused: $isSearchFocused
            )
            
            CommunitySortDropdown(
                selection: Binding(
                    get: { store.sortMode },
                    set: { store.send(.sortModeSelected($0)) }
                ),
                isOpen: Binding(
                    get: { store.isSortMenuOpen },
                    set: { store.send(.sortMenuOpenChanged($0)) }
                )
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .zIndex(1)
    }
    
    var postsScrollView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(store.displayedPosts) { post in
                    postCardLink(for: post)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .scrollDismissesKeyboard(.immediately)
        .onTapGesture {
            if isSearchFocused { isSearchFocused = false }
            if store.isSortMenuOpen { store.send(.outsideTapped) }
        }
    }
    
    func postCardLink(for post: Post) -> some View {
        NavigationLink {
            CommunityDetailView(
                store: Store(
                    initialState: CommunityDetailState(
                        post: post,
                        currentUserID: store.currentUserID
                    )
                ) {
                    CommunityDetailReducer()
                }
            )
        } label: {
            CommunityCard(
                post: post,
                onLikeTapped: { store.send(.likeTapped(postID: post.id)) },
                onCardTapped: {}
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("게시글 다수") {
    let me = UUID()
    let other = UUID()
    let third = UUID()
    
    let posts: [Post] = [
        Post(
            author: Author(id: other, name: "방울이아빠", profileImageURL: nil),
            title: "오늘 우리 콩이를 보냈어요",
            content: "오랜 시간 함께한 아이를 보내는 일이 이렇게 힘든 줄 몰랐어요.",
            createdAt: Date().addingTimeInterval(-3600),
            imageURLs: [],
            likeCount: 12,
            isLiked: false,
            comments: []
        ),
        Post(
            author: Author(id: third, name: "초코이모", profileImageURL: nil),
            title: "산책 사진 모음",
            content: "오늘 우리 콩이랑 같이 다닌 곳들이에요.",
            createdAt: Date().addingTimeInterval(-7200),
            imageURLs: ["https://picsum.photos/seed/a/400/400"],
            likeCount: 25,
            isLiked: true,
            comments: []
        ),
        Post(
            author: Author(id: me, name: "달콩이엄마", profileImageURL: nil),
            title: "강아지 사료 추천 부탁드려요",
            content: "10살 노견인데 신장 수치가 안 좋아져서 신장 케어 사료를 찾고 있어요.",
            createdAt: Date().addingTimeInterval(-86400),
            imageURLs: [],
            likeCount: 3,
            isLiked: false,
            comments: []
        ),
    ]
    
    return NavigationStack {
        CommunityView(
            store: Store(
                initialState: CommunityState(currentUserID: me, posts: posts)
            ) {
                CommunityReducer()
            }
        )
    }
}

#Preview("빈 상태") {
    NavigationStack {
        CommunityView(
            store: Store(
                initialState: CommunityState(currentUserID: UUID(), posts: [])
            ) {
                CommunityReducer()
            }
        )
    }
}
