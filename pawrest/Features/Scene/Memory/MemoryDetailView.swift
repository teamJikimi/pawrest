//
//  MemoryDetailView.swift
//  pawrest
//
//  Created by 곽예리 on 5/22/26.
//

import SwiftUI

// MARK: - Memory Detail View

struct MemoryDetailView: View {
    let images: [UIImage]
    let date: String
    let title: String
    let content: String
    
    let onClose: () -> Void
    
    var body: some View {
        ZStack {
            AppColor.rowMuted.color
                .ignoresSafeArea()
                .onTapGesture {
                    onClose()
                }
            
            AlbumDetailCard(
                images: images,
                date: date,
                title: title,
                content: content,
                onClose: {
                    onClose()
                }
            )
        }
    }
}


