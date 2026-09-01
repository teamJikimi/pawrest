//
//  CommunityWriteView.swift
//  pawrest
//
//  Created by Moon AYoung on 6/7/26.
//

import SwiftUI
import ComposableArchitecture
import Photos

struct CommunityWriteView: View {
    
    //MARK: - Properties
    
    @Bindable var store: StoreOf<CommunityWriteReducer>
    @FocusState private var isFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    var onSave: ((String, String, [UIImage]) -> Void)? = nil
    
    //MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    imageGridSection
                        .padding(.top, 16)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        titleTextField
                        contentTextField
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 12)
                
                saveButton
                    .padding(.horizontal, 20)
            }
            .scrollDismissesKeyboard(.immediately)
            .onTapGesture {
                isFocused = false
            }
        }
        .customNavigationBar(
            store: store.scope(
                state: \.navigationBar,
                action: \.navigationBar
            )
        )
        .onAppear {
            if store.isEditMode {
                store.send(.loadExistingImages)
            }
        }
        .onChange(of: store.shouldDismiss) { _, shouldDismiss in
            if shouldDismiss { dismiss() }
        }
        .hideTabBar()
    }
}

// MARK: - Subviews

private extension CommunityWriteView {
    
    var imageGridSection: some View {
        ImagePickerGrid(
            selectedImages: store.imageGrid.selectedImages,
            pickerItems: store.imageGrid.pickerItems,
            maxCount: 10,
            onImagesChanged: { images in
                store.send(.imageGrid(.imagesChanged(images)))
            },
            onPickerItemsChanged: { items in
                store.send(.imageGrid(.pickerItemsChanged(items)))
            }
        )
        .frame(height: 135)
        .onAppear {
            requestPhotoLibraryPermission()
        }
    }
    
    var titleTextField: some View {
        TextField(
            "제목을 입력하세요.",
            text: $store.title.sending(\.titleChanged)
        )
        .typography(.body2R1)
        .focused($isFocused)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .frame(height: 45)
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = true
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.gray10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray20, lineWidth: 1)
        )
        .onChange(of: store.title) { oldValue, newValue in
            if newValue.count > 22 {
                store.send(.titleChanged(String(newValue.prefix(22))))
            }
        }
    }
    
    var contentTextField: some View {
        LimitedTextField(
            text: $store.content.sending(\.contentChanged),
            isFocused: $isFocused,
            placeholder: "떠오르는 순간을 적어보세요.\n기록은 마음을 정리하는 작은 시작이 될 수 있어요.",
            maxCharacters: 1000
        )
    }
    
    var saveButton: some View {
        Button {
            onSave?(store.title, store.content, store.imageGrid.selectedImages)
            store.send(.saveButtonTapped)
        } label: {
            Text("저장하기")
                .typography(.button)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(store.isSaveButtonEnabled ? .pawPrimary : .gray40)
                .cornerRadius(14, corners: .allCorners)
        }
        .disabled(!store.isSaveButtonEnabled)
        .padding(.bottom, 20)
    }
    
    // MARK: - Helper
    
    func requestPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                print("📸 사진 권한: \(newStatus)")
            }
        case .authorized, .limited:
            break
        case .denied, .restricted:
            print("❌ 사진 권한 거부됨")
        @unknown default:
            break
        }
    }
}
