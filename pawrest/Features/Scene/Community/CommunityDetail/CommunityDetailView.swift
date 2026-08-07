//
//  CommunityDetailView.swift
//  pawrest
//
//  Created by Moon AYoung on 6/1/26.
//

import SwiftUI
import UIKit
import ComposableArchitecture

struct CommunityDetailView: View {
    @Bindable var store: StoreOf<CommunityDetailReducer>
    @FocusState private var isInputFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    var onPostStateUpdated: ((Post) -> Void)? = nil
    var onPostDeleted: ((String) -> Void)? = nil
    
    var body: some View {
        contentView
            .safeAreaInset(edge: .bottom, spacing: 0){
                inputBar
            }
            .customNavigationBar(
                store: store.scope(
                    state: \.navigationBar,
                    action: \.navigationBar
                )
            )
            .onChange(of: store.replyingToCommentID) { _, newValue in
                if newValue != nil {
                    isInputFocused = true
                }
            }
            .onChange(of: store.shouldDismiss) { _, shouldDismiss in
                if shouldDismiss {
                    if store.isDeleted {
                        onPostDeleted?(store.post.id) }
                    dismiss()
                }
            }
            .onChange(of: store.post) { _, newPost in
                onPostStateUpdated?(newPost)
            }
        
            .onChange(of: store.post.commentCount) { oldCount, newCount in
                if newCount > oldCount {
                    isInputFocused = false
                }
            }
            .sheet(
                isPresented: Binding(
                    get: { store.isEditPresented },
                    set: { isPresented in
                        if !isPresented {
                            store.send(.editDismissed)
                        }
                    }
                )
            ) {
                NavigationStack {
                    editView
                }
            }
    }
}

//MARK: - ContentView

private extension CommunityDetailView {
    
    var contentView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                authorHeaderSection
                CommunityDivider()
                contentSection
                if !store.post.imageURLs.isEmpty {
                    imageSection
                }
                CommunityDivider()
                    .padding(.top, 18)
                likeCommentBarSection
                CommunityDivider()
                commentsSection
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .onTapGesture {
            if isInputFocused {
                isInputFocused = false
                store.send(.outsideTapped)
            }
        }
    }
}

// MARK: - SubView

private extension CommunityDetailView {
    
    var authorHeaderSection: some View {
        CommunityAuthorHeader(
            author: store.post.author,
            date: store.post.createdAt
        )
        .padding(.vertical, 18)
        .padding(.horizontal, 20)
    }
    
    var contentSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(store.post.title)
                .typography(.body1Accent)
                .foregroundColor(.gray80)
                .padding(.top, 18)
            
            Text(store.post.content)
                .typography(.body2R2)
                .foregroundColor(.gray80)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 12)
        }
        .padding(.horizontal, 20)
    }
    
    var imageSection: some View {
        VStack(spacing: 12) {
            ForEach(store.post.imageURLs, id: \.self) { url in
                AsyncImage(url: URL(string: url)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    Rectangle()
                        .fill(.gray10)
                        .aspectRatio(1, contentMode: .fit)
                }
                .frame(maxWidth: .infinity)
                .cornerRadius(12, corners: .allCorners)
            }
        }
        .padding(.top, 12)
        .padding(.horizontal, 20)
    }
    
    var likeCommentBarSection: some View {
        CommunityLikeCommentBar(
            likeCount: store.post.likeCount,
            commentCount: store.post.commentCount,
            size: .large,
            isLiked: store.post.isLiked,
            onLikeTapped: { store.send(.likeTapped) }
        )
        .padding(.vertical, 15)
        .padding(.horizontal, 20)
    }
    
    var commentsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(store.post.comments.enumerated()), id: \.element.id) { idx, parent in
                commentGroup(
                    parent: parent,
                    isLastGroup: idx == store.post.comments.count - 1
                )
            }
        }
        .padding(.top, 20)
    }
    
    @ViewBuilder
    func commentGroup(parent: Comment, isLastGroup: Bool) -> some View {
        CommunityCommentRow(
            comment: parent,
            isReply: false,
            isMyComment: parent.author.id == store.currentUserID,
            opensMenuUpward: isLastGroup && parent.replies.isEmpty,
            onAction: { action in
                store.send(.commentAction(commentID: parent.id, action: action))
            }
        )
        .padding(.horizontal, 20)
        
        if !parent.replies.isEmpty {
            Color.clear.frame(height: 18)
            
            ForEach(Array(parent.replies.enumerated()), id: \.element.id) { rIdx, reply in
                if rIdx > 0 {
                    Color.clear.frame(height: 6)
                }
                
                CommunityCommentRow(
                    comment: reply,
                    isReply: true,
                    isMyComment: reply.author.id == store.currentUserID,
                    opensMenuUpward: isLastGroup && rIdx == parent.replies.count - 1,
                    onAction: { action in
                        store.send(.commentAction(commentID: reply.id, action: action))
                    }
                )
                .padding(.horizontal, 20)
            }
        }
        
        if !isLastGroup {
            Color.clear.frame(height: 20)
            CommunityDivider(horizontalPadding: 20)
            Color.clear.frame(height: 20)
        } else {
            Color.clear.frame(height: parent.replies.isEmpty ? 20 : 16)
        }
    }
    
    var inputBar: some View {
        CommunityCommentInputBar(
            text: Binding(
                get: { store.text },
                set: { store.send(.textChanged($0)) }
            ),
            onSend: { store.send(.sendTapped) },
            placeholder: store.inputPlaceholder,
            isFocused: $isInputFocused
        )
    }
}

//MARK: - EditView

private extension CommunityDetailView {
    
    var editView: some View {
        CommunityWriteView(
            store: Store(
                initialState: CommunityWriteState(editingPost: store.post),
                reducer: { CommunityWriteReducer() }
            ),
            onSave: editSave
        )
    }
    
    func editSave(title: String, content: String, images: [UIImage]) {
        let imageDatas = images.compactMap {
            $0.jpegData(compressionQuality: 0.8)
        }
        store.send(.postEdited(
            title: title,
            content: content,
            imageDatas: imageDatas
        ))
    }
}
