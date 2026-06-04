//
//  CommunityLikeCommentBar.swift
//  pawrest
//
//  Created by Moon AYoung on 5/27/26.
//

import SwiftUI

struct CommunityLikeCommentBar: View {
    
    //MARK: - properties
    
    enum Size {
        case large // -> 글 상세보기
        case small // -> 커뮤니티 메인(썸네일 카드), 나의 글 관리
    }
    
    let likeCount: Int
    let commentCount: Int
    
    var size: Size = .small
    
    var isLiked: Bool = false
    var showsCount: Bool = true
    var onLikeTapped: () -> Void = {}
    
    //MARK: - body
    
    var body: some View{
        HStack(spacing: groupSpacing) {
            likeButton
            commentLabel
        }
    }
}

//MARK: - Subviews

private extension CommunityLikeCommentBar {
    
    private var likeButton: some View {
        Button(action: onLikeTapped) {
            
            HStack(spacing: 4) {
                Image(heartIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                
                if showsCount {
                    Text("\(likeCount)")
                        .typography(countFont)
                        .foregroundColor(.gray50)
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    private var commentLabel: some View {
        HStack(spacing: 4) {
            Image(commentIcon)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
            
            if showsCount {
                Text("\(commentCount)")
                    .typography(countFont)
                    .foregroundColor(.gray50)
            }
        }
    }
}

// MARK: - Helper

private extension CommunityLikeCommentBar {
    
    var groupSpacing: CGFloat {
        switch size {
        case .large: return 12
        case .small: return 8
        }
    }
    
    var heartIcon: ImageResource {
        switch (size, isLiked) {
        case (.large, true):  return .iconHeartLargeActive
        case (.large, false): return .iconHeartLargeDefault
        case (.small, true):  return .iconHeartSmallActive
        case (.small, false): return .iconHeartSmallDefault
        }
    }
    
    var commentIcon: ImageResource {
        size == .large ? .iconCommentLarge : .iconCommentSmall
    }
    
    var iconSize: CGFloat {
        size == .large ? 24 : 18
    }
    
    var countFont: AppTypography {
        .body2R1
    }
}
