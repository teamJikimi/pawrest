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

            if store.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            isPresented: Binding(
                get: { store.isMyPostPresented },
                set: { if !$0 { store.send(.myPostDismissed) } }
            )
        ) {
            if let currentUserID = store.currentUserID {
                CommunityMyPostView(
                    store: Store(
                        initialState: CommunityMyPostState(
                            currentUserID: currentUserID,
                            posts: store.posts,
                            authorName: store.authorName ?? ""
                        ),
                        reducer: { CommunityMyPostReducer() }
                    ),
                    onPostsUpdated: { updatedPosts in
                        store.send(.myPostsUpdated(posts: updatedPosts))
                    }
                )
            }
        }
        .navigationDestination(
            isPresented: Binding(
                get: { store.isWritePostPresented },
                set: { if !$0 { store.send(.writePostDismissed) } }
            )
        ) {
            CommunityWriteView(
                store: Store(
                    initialState: CommunityWriteState(),
                    reducer: { CommunityWriteReducer() }
                ),
                onSave: { title, content, images in
                    let imageDatas = images.compactMap {
                        $0.jpegData(compressionQuality: 0.8)
                    }
                    store.send(.newPostCreated(
                        title: title,
                        content: content,
                        imageDatas: imageDatas
                    ))
                }
            )
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
                    postCardLink(for: post)
                }
            }
            .padding(.horizontal, 20)
        }
        .scrollDismissesKeyboard(.immediately)
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

    @ViewBuilder
    func postCardLink(for post: Post) -> some View {
        if let currentUserID = store.currentUserID {
            NavigationLink {
                CommunityDetailView(
                    store: Store(
                        initialState: CommunityDetailState(
                            post: post,
                            currentUserID: currentUserID,
                            authorName: store.authorName ?? ""
                        ),
                        reducer: { CommunityDetailReducer() }
                    ),
                    onPostStateUpdated: { updatedPost in
                        store.send(.postStateUpdated(updatedPost))
                    },
                    onPostDeleted: { postID in
                        store.send(.postDeleted(postID))
                    }
                )
                .onAppear {
                    store.send(.detailPresented)
                }
                .onDisappear {
                    store.send(.detailDismissed)
                }
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
