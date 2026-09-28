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
        .task {
            await store.send(.onAppear).finish()
        }
        .navigationDestination(
            item: $store.scope(state: \.detail, action: \.detail)
        ) { detailStore in
            CommunityDetailView(store: detailStore)
        }
        .hideTabBar()
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
                    postCard(for: post)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Color.clear.frame(height: 80)
        }
    }
    
    func postCard(for post: Post) -> some View {
        Button {
            store.send(.postTapped(postID: post.id))
        } label: {
            CommunityCard(
                post: post,
                onLikeTapped: { store.send(.likeTapped(postID: post.id)) }
            )
        }
        .buttonStyle(.plain)
    }
}
