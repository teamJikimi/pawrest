//
//  CommunityDetailView.swift
//  pawrest
//
//  Created by Moon AYoung on 6/1/26.
//

import SwiftUI
import ComposableArchitecture

struct CommunityDetailView: View {
    @Bindable var store: StoreOf<CommunityDetailReducer>
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
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
    }
}

// MARK: - Sections

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
                .typography(.title2)
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

// MARK: - Preview

#Preview("타인의 글") {
    let me = UUID()
    let other = UUID()
    let third = UUID()
    
    let meAuthor = Author(id: me, name: "달콩이엄마", profileImageURL: nil)
    let otherAuthor = Author(id: other, name: "방울이아빠", profileImageURL: nil)
    let thirdAuthor = Author(id: third, name: "초코이모", profileImageURL: nil)
    
    let comment1 = Comment(
        content: "이 글 너무 공감돼요. 저도 비슷한 시기를 보냈어요.",
        author: otherAuthor,
        createdAt: Date(),
        replies: [
            Comment(content: "저도 한참 그랬어요.", author: thirdAuthor, createdAt: Date()),
            Comment(content: "감사합니다 ㅠㅠ", author: meAuthor, createdAt: Date()),
        ]
    )
    let comment2 = Comment(
        content: "오랜만에 좋은 글 봅니다.",
        author: meAuthor,
        createdAt: Date()
    )
    
    let post = Post(
        author: otherAuthor,
        title: "오늘 우리 콩이를 보냈어요",
        content: """
        오랜 시간 함께한 아이를 보내는 일이 이렇게 힘든 줄 몰랐어요. \
        벌써 일주일이 지났는데도 빈 자리가 너무 크게 느껴져서, \
        이렇게 글이라도 남겨봅니다.
        """,
        createdAt: Date(),
        imageURLs: [],
        likeCount: 12,
        isLiked: false,
        comments: [comment1, comment2]
    )
    
    return NavigationStack {
        CommunityDetailView(
            store: Store(
                initialState: CommunityDetailState(post: post, currentUserID: me)
            ) {
                CommunityDetailReducer()
            }
        )
    }
}

#Preview("내 글 + 댓글 없음") {
    let me = UUID()
    let meAuthor = Author(id: me, name: "달콩이엄마", profileImageURL: nil)
    
    let post = Post(
        author: meAuthor,
        title: "짧은 제목 테스트",
        content: "짧은 본문.",
        createdAt: Date(),
        imageURLs: [],
        likeCount: 0,
        isLiked: false,
        comments: []
    )
    
    return NavigationStack {
        CommunityDetailView(
            store: Store(
                initialState: CommunityDetailState(post: post, currentUserID: me)
            ) {
                CommunityDetailReducer()
            }
        )
    }
}
