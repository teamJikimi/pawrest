//
//  CommunityView.swift
//  pawrest
//
//  Created by 소은 on 5/17/26.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

struct CommunityView: View {
    @Bindable var store: StoreOf<CommunityReducer>
    @FocusState private var isSearchFocused: Bool
    @Query private var userProfiles: [UserProfile]

    var body: some View {
        VStack(spacing: 0) {
            searchAndSortSection

            if store.isLoading && store.posts.isEmpty {
                LoadingView()
            } else if store.displayedPosts.isEmpty {
                emptyStateView
            } else {
                postsScrollView
            }
        }
        .task {
            let nickname = userProfiles
                .sorted { $0.createdAt > $1.createdAt }
                .first?
                .nickname

            store.send(.userProfileLoaded(nickname))
            store.send(.onAppear)
        }
        .onAppear {
            store.send(.refreshBlockedUsers)
        }
        .customNavigationBar(
            store: store.scope(
                state: \.navigationBar,
                action: \.navigationBar
            )
        )
        .navigationDestination(
            item: $store.scope(state: \.myPost, action: \.myPost)
        ) { myPostStore in
            CommunityMyPostView(store: myPostStore)
        }
        .navigationDestination(
            item: $store.scope(state: \.detail, action: \.detail)
        ) { detailStore in
            CommunityDetailView(store: detailStore)
        }
        .navigationDestination(
            item: $store.scope(state: \.write, action: \.write)
        ) { writeStore in
            CommunityWriteView(store: writeStore)
        }
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
                    postCard(for: post)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .scrollDismissesKeyboard(.immediately)
        .refreshable {
            await store.send(.refreshPulled).finish()
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Color.clear.frame(height: 80)
        }
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    if isSearchFocused {
                        isSearchFocused = false
                    }

                    if store.isSortMenuOpen {
                        store.send(.outsideTapped)
                    }
                }
        )
    }

    func postCard(for post: Post) -> some View {
        Button {
            store.send(.postTapped(postID: post.id))
        } label: {
            CommunityCard(
                post: post,
                onLikeTapped: {
                    store.send(.likeTapped(postID: post.id))
                }
            )
        }
        .buttonStyle(.plain)
    }

    var emptyStateView: some View {
        GeometryReader { geo in
            VStack(spacing: 8) {
                Image(.iconSearch)

                Text("검색 결과가 없습니다")
                    .typography(.body3R)
                    .foregroundColor(.gray60)
            }
            .frame(maxWidth: .infinity)
            .position(
                x: geo.size.width / 2,
                y: geo.size.height * 234.0 / 604.0
            )
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if isSearchFocused {
                isSearchFocused = false
            }

            if store.isSortMenuOpen {
                store.send(.outsideTapped)
            }
        }
    }
}
