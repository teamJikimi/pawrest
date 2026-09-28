//
//  CommunityImageGrid.swift
//  pawrest
//
//  Created by Moon AYoung on 9/21/26.
//

import SwiftUI
import PhotosUI

struct CommunityImageGrid: View {
    
    // MARK: - Properties
    
    let items: [PostImageItem]
    let maxCount: Int
    let onImagesAdded: ([UIImage]) -> Void
    let onImageDeleted: (PostImageItem.ID) -> Void
    
    @State private var pickerItems: [PhotosPickerItem] = []
    
    // MARK: - Body
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ImagePickerGrid.AddButton(
                    selectedCount: items.count,
                    maxCount: maxCount,
                    localPickerItems: $pickerItems,
                    onPickerItemsChanged: { _ in },
                    onImagesLoaded: loadImages
                )
                
                ForEach(items) { item in
                    ImageCard(
                        item: item,
                        onDelete: { onImageDeleted(item.id) }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Actions

private extension CommunityImageGrid {
    
    func loadImages(from selection: [PhotosPickerItem]) {
        guard !selection.isEmpty else { return }
        pickerItems = []
        
        Task {
            var images: [UIImage] = []
            
            for item in selection {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    images.append(image)
                }
            }
            
            onImagesAdded(images)
        }
    }
}

// MARK: - Subviews

extension CommunityImageGrid {
    
    struct ImageCard: View {
        let item: PostImageItem
        let onDelete: () -> Void
        
        var body: some View {
            ZStack(alignment: .topTrailing) {
                imageContent
                    .frame(width: 103, height: 135)
                    .cornerRadius(10, corners: .allCorners)
                deleteButton
            }
        }
        
        @ViewBuilder
        private var imageContent: some View {
            switch item.source {
            case .remote(let urlString):
                CachedAsyncImage(url: URL(string: urlString), contentMode: .fill, maxPixelSize: 400) {
                    Rectangle()
                        .fill(.gray10)
                }
            case .local(let image):
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            }
        }
        
        private var deleteButton: some View {
            Image(.iconImageXmark)
                .frame(width: 24, height: 24)
                .padding(8)
                .contentShape(Rectangle())
                .highPriorityGesture(
                    TapGesture().onEnded {
                        onDelete()
                    }
                )
        }
    }
}
