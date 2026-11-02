//
//  CommunityAuthorHeader.swift
//  pawrest
//
//  Created by Moon AYoung on 5/27/26.
//

import SwiftUI
import Kingfisher

enum CommunityAuthorNameStyle {
    case card
    case comment
}

struct CommunityAuthorHeader: View {
    
    //MARK: - Properties
    
    let author: Author
    let date: Date
    var profileSize: CGFloat = 32
    var nameStyle: CommunityAuthorNameStyle = .card
    
    
    //MARK: - Body
    
    var body: some View {
        HStack(spacing: 8) {
            profileImage
            
            VStack(alignment: .leading, spacing: 4) {
                authorName
                
                Text(date.formattedAuthorHeader)
                    .typography(.date)
                    .foregroundColor(.gray50)
            }
            
            Spacer(minLength: 0)
        }
    }
}

    //MARK: - Subviews

private extension CommunityAuthorHeader {
    
    @ViewBuilder
    var authorName: some View {
        switch nameStyle {
        case .card:
            Text(author.name)
                .typography(.body2Accent)
                .foregroundColor(.gray80)
        case .comment:
            Text(author.name)
                .typography(.body3Accent)
                .foregroundColor(.gray80)
        }
    }
    
    @ViewBuilder
    var profileImage: some View {
        if let urlString = author.profileImageURL,
           let url = URL(string: urlString) {
            KFImage(url)
                .resizable()
                .scaledToFill()
                .frame(width: profileSize, height: profileSize)
                .clipShape(Circle())
        } else {
            defaultProfileImage
        }
    }
    
    var defaultProfileImage: some View {
        Image(.profileLarge)
            .resizable()
            .scaledToFill()
            .frame(width: profileSize, height: profileSize)
            .clipShape(Circle())
    }
    
}
