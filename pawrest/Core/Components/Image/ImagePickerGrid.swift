//
//  ImagePickerGrid.swift
//  pawrest
//
//  Created by 소은 on 5/21/26.
//

import SwiftUI
import PhotosUI

public struct ImagePickerGrid: View {
    let selectedImages: [UIImage]
    let pickerItems: [PhotosPickerItem]
    let maxCount: Int
    let onImagesChanged: ([UIImage]) -> Void
    let onPickerItemsChanged: ([PhotosPickerItem]) -> Void
    
    public init(
        selectedImages: [UIImage],
        pickerItems: [PhotosPickerItem],
        maxCount: Int = 10,
        onImagesChanged: @escaping ([UIImage]) -> Void,
        onPickerItemsChanged: @escaping ([PhotosPickerItem]) -> Void
    ) {
        self.selectedImages = selectedImages
        self.pickerItems = pickerItems
        self.maxCount = maxCount
        self.onImagesChanged = onImagesChanged
        self.onPickerItemsChanged = onPickerItemsChanged
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                addButton
                
                ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                    ImageCard(
                        image: image,
                        onDelete: { removeImage(at: index) }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Add Button
    
    @State private var localPickerItems: [PhotosPickerItem] = []
    
    private var addButton: some View {
        PhotosPicker(
            selection: $localPickerItems,
            maxSelectionCount: maxCount,
            matching: .images
        ) {
            VStack(spacing: 12) {
                Image(.iconAdd)
                
                Text("\(selectedImages.count)/\(maxCount)")
                    .typography(.body2R1)
                    .foregroundStyle(.gray80)
            }
            .frame(width: 103, height: 135)
            .background(.gray20)
            .cornerRadius(10)
        }
        .onChange(of: localPickerItems) { _, newItems in
            onPickerItemsChanged(newItems)
            loadImages(from: newItems)
        }
        .disabled(selectedImages.count >= maxCount)
        .opacity(selectedImages.count >= maxCount ? 0.5 : 1.0)
    }
    
    // MARK: - Actions
    
    private func loadImages(from items: [PhotosPickerItem]) {
        Task {
            var loadedImages: [UIImage] = []
            
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    loadedImages.append(uiImage)
                }
            }
            
            await MainActor.run {
                onImagesChanged(loadedImages)
            }
        }
    }
    
    private func removeImage(at index: Int) {
        var newImages = selectedImages
        var newItems = pickerItems
        
        newImages.remove(at: index)
        if index < newItems.count {
            newItems.remove(at: index)
        }
        
        onImagesChanged(newImages)
        onPickerItemsChanged(newItems)
    }
}

// MARK: - ImageCard

extension ImagePickerGrid {
    struct ImageCard: View {
        let image: UIImage
        let onDelete: () -> Void
        
        var body: some View {
            ZStack(alignment: .topTrailing) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 103, height: 135)
                    .cornerRadius(10)
                
                Button(action: onDelete) {
                    Image(.iconImageXmark)
                        .frame(width: 24, height: 24)
                }
                .padding(8)
            }
        }
    }
}
