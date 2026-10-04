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
    let maxCount: Int
    let onImagesChanged: ([UIImage]) -> Void

    @State private var localPickerItems: [PhotosPickerItem] = []

    // MARK: - Initializer

    public init(
        selectedImages: [UIImage],
        maxCount: Int = 10,
        onImagesChanged: @escaping ([UIImage]) -> Void
    ) {
        self.selectedImages = selectedImages
        self.maxCount = maxCount
        self.onImagesChanged = onImagesChanged
    }

    // MARK: - Body

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                AddButton(
                    selectedCount: selectedImages.count,
                    maxCount: maxCount,
                    localPickerItems: $localPickerItems,
                    onItemsChanged: { oldItems, newItems in
                        handlePickerChange(from: oldItems, to: newItems)
                    }
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

    private func handlePickerChange(from oldItems: [PhotosPickerItem], to newItems: [PhotosPickerItem]) {
        guard oldItems != newItems else { return }

        if newItems.count >= oldItems.count {
            let addedItems = Array(newItems.suffix(newItems.count - oldItems.count))
            guard !addedItems.isEmpty else { return }
            Task {
                var addedImages: [UIImage] = []
                for item in addedItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        addedImages.append(uiImage)
                    }
                }
                await MainActor.run {
                    onImagesChanged(selectedImages + addedImages)
                }
            }
        } else {
            let removedCount = oldItems.count - newItems.count
            onImagesChanged(Array(selectedImages.dropLast(removedCount)))
        }
    }

    private func removeImage(at index: Int) {
        var newImages = selectedImages
        newImages.remove(at: index)
        if index < localPickerItems.count {
            localPickerItems.remove(at: index)
        }
        onImagesChanged(newImages)
    }
}

// MARK: - Subviews

extension ImagePickerGrid {
    public struct AddButton: View {
        let selectedCount: Int
        let maxCount: Int
        @Binding var localPickerItems: [PhotosPickerItem]
        let onItemsChanged: ([PhotosPickerItem], [PhotosPickerItem]) -> Void

        public var body: some View {
            PhotosPicker(
                selection: $localPickerItems,
                maxSelectionCount: maxCount,
                matching: .images
            ) {
                content
            }
            .onChange(of: localPickerItems) { oldItems, newItems in
                onItemsChanged(oldItems, newItems)
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
                    .foregroundStyle(.gray80)

                Text("\(selectedCount)/\(maxCount)")
                    .typography(.body2R1)
                    .foregroundStyle(.gray80)
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
