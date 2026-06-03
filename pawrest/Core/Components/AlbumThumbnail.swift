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
    let size: CGFloat
    
    init(title: String, image: UIImage?, size: CGFloat = 162) {
        self.title = title
        self.image = image
        self.size = size
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipped()
                
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.5),
                        .init(color: .black.opacity(0.35), location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: size, height: size)
            } else {
                AppColor.pawPrimary.color
                    .frame(width: size, height: size)
            }
            
            Text(title)
                .typography(.body2M)
                .foregroundColor(.white)
                .lineLimit(1)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
        }
        .frame(width: size, height: size) 
        .cornerRadius(20, corners: .allCorners)
    }
}
