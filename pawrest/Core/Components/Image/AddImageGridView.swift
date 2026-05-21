//
//  AddImageGridView.swift
//  pawrest
//
//  Created by 소은 on 5/21/26.
//

import SwiftUI
import ComposableArchitecture
import PhotosUI
import Photos

public struct AddImageGridView: View {
    let store: StoreOf<AddImageGridFeature>
    
    public init(store: StoreOf<AddImageGridFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ImagePickerGrid(
            selectedImages: store.selectedImages,
            pickerItems: store.pickerItems,
            maxCount: 10,
            onImagesChanged: { images in
                store.send(.imagesChanged(images))
            },
            onPickerItemsChanged: { items in
                store.send(.pickerItemsChanged(items))
            }
        )
        .onAppear {
            requestPhotoLibraryPermission()
        }
    }
    
    // MARK: - 권한 요청
    
    private func requestPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                print("📸 사진 권한: \(newStatus)")
            }
        case .authorized, .limited:
            print(" 사진 권한 허용됨")
        case .denied, .restricted:
            print(" 사진 권한 거부됨")
        @unknown default:
            break
        }
    }
}
