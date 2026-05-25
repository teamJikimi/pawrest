//
//  AlbumThumbnail.swift
//  pawrest
//
//  Created by 곽예리 on 5/20/26.
//

import SwiftUI

// MARK: - Album Thumbnail

struct AlbumThumbnail: View {
    let title: String
    let image: UIImage?
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 162, height: 162)
                    .clipped()
                
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.5),
                        .init(color: .black.opacity(0.35), location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: 162, height: 162)
            } else {
                AppColor.pawPrimary.color
                    .frame(width: 162, height: 162)
            }
            
            Text(title)
                .typography(.body2M)
                .foregroundColor(.white)
                .lineLimit(1)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
        }
        .frame(width: 162, height: 162)
        .cornerRadius(20)
    }
}
