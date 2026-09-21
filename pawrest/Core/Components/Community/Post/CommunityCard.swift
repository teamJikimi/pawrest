//
//  CommunityCard.swift
//  pawrest
//
//  Created by Moon AYoung on 5/27/26.
//

import SwiftUI

struct CommunityCard: View {
    
    //MARK: - Properties
    
    let post: Post
    var showsCount: Bool = true
    var onLikeTapped: () -> Void = {}
    
    //MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            CommunityAuthorHeader(author: post.author, date: post.createdAt)
            
            contentSection
                .padding(.top, 18)
            
            if !post.imageURLs.isEmpty {
                imageSection
                    .padding(.top, 12)
            }
            
            CommunityDivider()
                .padding(.top, 18)
            
            CommunityLikeCommentBar(
                likeCount: post.likeCount,
                commentCount: post.commentCount,
                size: .small,
                isLiked: post.isLiked,
                showsCount: showsCount,
                onLikeTapped: onLikeTapped
            )
            .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        
        .background(.gray0)
        
        .cornerRadius(20, corners: .allCorners)
        
        .overlay{
            RoundedRectangle(cornerRadius: 20)
                .stroke(.gray20, lineWidth: 1)
        }
    }
}


// MARK: - Subviews

private extension CommunityCard {
    
    var contentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(post.title)
                .typography(.body1Accent)
                .foregroundColor(.gray80)
            
            Text(post.content)
                .typography(.body2R2)
                .foregroundColor(.gray80)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var imageSection: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                CachedAsyncImage(
                    url: URL(string: post.imageURLs[0]),
                    contentMode: .fill,
                    maxPixelSize: 800
                ) {
                    Rectangle()
                        .fill(.gray10)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(alignment: .topTrailing) {
                if post.imageURLs.count > 1 {
                    countBadge
                }
            }
    }

    var countBadge: some View {
        ZStack {
            Circle()
                .fill(.black.opacity(0.5))
                .frame(width: 24, height: 24)
            
            Text("\(post.imageURLs.count)")
                .typography(.body2R1)
                .foregroundColor(.gray0)
        }
        .padding(16)
    }
    
}
