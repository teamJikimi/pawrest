//
//  ImagePickerGrid.swift
//  pawrest
//
//  Created by 소은 on 5/21/26.
//

import SwiftUI
import PhotosUI

public struct ImagePickerGrid: View {
    // MARK: - Properties
    
    let selectedImages: [UIImage]
    let pickerItems: [PhotosPickerItem]
    let maxCount: Int
    let onImagesChanged: ([UIImage]) -> Void
    let onPickerItemsChanged: ([PhotosPickerItem]) -> Void
    
    @State private var localPickerItems: [PhotosPickerItem] = []
    
    // MARK: - Initializer
    
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
    
    // MARK: - Body
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                AddButton(
                    selectedCount: selectedImages.count,
                    maxCount: maxCount,
                    localPickerItems: $localPickerItems,
                    onPickerItemsChanged: onPickerItemsChanged,
                    onImagesLoaded: loadImages
                )
                
                ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                    ImageCard(
                        image: image,
                        onDelete: { removeImage(at: index) }
                    )
                }
            }
            .padding(.horizontal, 20) 
        }
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

// MARK: - Subviews

extension ImagePickerGrid {
    struct AddButton: View {
        let selectedCount: Int
        let maxCount: Int
        @Binding var localPickerItems: [PhotosPickerItem]
        let onPickerItemsChanged: ([PhotosPickerItem]) -> Void
        let onImagesLoaded: ([PhotosPickerItem]) -> Void
        
        var body: some View {
            PhotosPicker(
                selection: $localPickerItems,
                maxSelectionCount: maxCount,
                matching: .images
            ) {
                content
            }
            .onChange(of: localPickerItems) { _, newItems in
                onPickerItemsChanged(newItems)
                onImagesLoaded(newItems)
            }
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.5 : 1.0)
        }
        
        private var content: some View {
            VStack(spacing: 12) {
                Image(.iconAdd)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(selectedCount == 0 ? .gray50 : .gray90)
                
                Text("\(selectedCount)/\(maxCount)")
                    .typography(.body2R1)
                    .foregroundStyle(selectedCount == 0 ? .gray50 : .gray90)
            }
            .frame(width: 103, height: 135)
            .background(.gray20)
            .cornerRadius(10, corners: .allCorners)
        }
        
        private var isDisabled: Bool {
            selectedCount >= maxCount
        }
    }
    
    struct ImageCard: View {
        let image: UIImage
        let onDelete: () -> Void
        
        var body: some View {
            ZStack(alignment: .topTrailing) {
                imageContent
                deleteButton
            }
        }
        
        private var imageContent: some View {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 103, height: 135)
                .cornerRadius(10, corners: .allCorners)
        }
        
        private var deleteButton: some View {
            Button(action: onDelete) {
                Image(.iconImageXmark)
                    .frame(width: 24, height: 24)
            }
            .padding(8)
        }
    }
}
