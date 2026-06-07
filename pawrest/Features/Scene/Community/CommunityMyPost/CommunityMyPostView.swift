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
    @Binding var isTabBarHidden: Bool
    @Environment(\.dismiss) private var dismiss
    
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
            if shouldDismiss { dismiss() }
        }
    }
}

// MARK: - Subviews

private extension CommunityMyPostView {
    
    var segmentSection: some View {
        SegmentTabBar(
            items: MyPostTab.allCases,
            selection: Binding(
                get: { store.selectedTab },
                set: { store.send(.tabChanged($0)) }
            )
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
            .onAppear { isTabBarHidden = true }
            .onDisappear { isTabBarHidden = false }
        } label: {
            CommunityCard(
                post: post,
                onLikeTapped: { store.send(.likeTapped(postID: post.id)) }
            )
        }
        .buttonStyle(.plain)
    }
}
