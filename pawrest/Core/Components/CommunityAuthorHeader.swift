//
//  CommunityAuthorHeader.swift
//  pawrest
//
//  Created by Moon AYoung on 5/27/26.
//

import SwiftUI

struct CommunityAuthorHeader: View {
    let author: Author
    let date: Date
    var profileSize: CGFloat = 32
    
    var body: some View {
        HStack(spacing: 8) {
            profileImage
            
            VStack(alignment: .leading, spacing: 4) {
                Text(author.name)
                    .typography(.body2Accent)
                    .foregroundColor(.gray80)
                
                Text(date, formatter: Self.dateFormatter)
                    .typography(.date)
                    .foregroundColor(.gray50)
            }
            
            Spacer(minLength: 0)
        }
    }
    
    @ViewBuilder
    private var profileImage: some View {
        if let urlString = author.profileImageURL,
           let url = URL(string: urlString) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                defaultProfileImage
            }
            .frame(width: profileSize, height: profileSize)
            .clipShape(Circle())
        } else {
            defaultProfileImage
        }
    }
    
    private var defaultProfileImage: some View {
        Image(.profileDefault)
            .resizable()
            .scaledToFill()
            .frame(width: profileSize, height: profileSize)
            .clipShape(Circle())
    }
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter
    }()
}
