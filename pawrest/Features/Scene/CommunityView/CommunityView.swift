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
//            .padding(.bottom, 20)
        }
        .scrollDismissesKeyboard(.immediately)
//        .onTapGesture {
//            if isSearchFocused { isSearchFocused = false }
//            if store.isSortMenuOpen { store.send(.outsideTapped) }
//        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Color.clear.frame(height: 80)
        }
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    if isSearchFocused { isSearchFocused = false }
                    if store.isSortMenuOpen { store.send(.outsideTapped) }
                }
        )
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
//                onCardTapped: {}
            )
        }
        .buttonStyle(.plain)
    }
}
