//
//  CommunityMyPostView.swift
//  pawrest
//
//  Created by Moon AYoung on 6/4/26.
//

import SwiftUI
import ComposableArchitecture

struct CommunityMyPostView: View {
    
    //MARK: - Properties
    
    @Bindable var store: StoreOf<CommunityMyPostReducer>
    @Environment(\.dismiss) private var dismiss
    
    var onPostsUpdated: (([Post]) -> Void)? = nil
    
    //MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            segmentSection
            postsScrollView
        }
        .customNavigationBar(
            store: store.scope(
                state: \.navigationBar,
                action: \.navigationBar
            )
        )
        .onChange(of: store.shouldDismiss) { _, shouldDismiss in
            if shouldDismiss {
                onPostsUpdated?(store.posts)
                dismiss()
            }
        }
    }
}

// MARK: - Subviews

private extension CommunityMyPostView {
    
    var segmentSection: some View {
        SegmentTabBar(
            items: MyPostTab.allCases,
            selection: $store.selectedTab.sending(\.tabChanged)
        )
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    var postsScrollView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(store.filteredPosts) { post in
                    postCardLink(for: post)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Color.clear.frame(height: 80)
        }
    }
    
    func postCardLink(for post: Post) -> some View {
        NavigationLink {
            CommunityDetailView(
                store: Store(
                    initialState: CommunityDetailState(
                        post: post,
                        currentUserID: store.currentUserID,
                        authorName: store.authorName
                    ),
                    reducer: { CommunityDetailReducer() }
                ),
                onPostStateUpdated: { updatedPost in
                    store.send(.postUpdatedFromDetail(post: updatedPost))
                },
                onPostDeleted: { postId in
                    store.send(.postDeleted(postId))
                }
            )
        } label: {
            CommunityCard(
                post: post,
                onLikeTapped: { store.send(.likeTapped(postID: post.id)) }
            )
        }
        .buttonStyle(.plain)
    }
}
