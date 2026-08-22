//
//  AddMemoryView.swift
//  pawrest
//
//  Created by 소은 on 5/21/26.
//

import SwiftUI
import SwiftData
import ComposableArchitecture
import Photos

struct AddMemoryView: View {
    @Bindable var store: StoreOf<AddMemoryReducer>
    @FocusState private var isFocused: Bool
    
    @Environment(\.modelContext) private var modelContext
    
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
        .navigationBarBackButtonHidden(true)
        .customNavigationBar(
            store: store.scope(
                state: \.navigationBar,
                action: \.navigationBar
            )
        )
        .onChange(of: store.state) { oldValue, newValue in }
        .hideTabBar()
    }
}

// MARK: - Subviews

extension AddMemoryView {
    private var imageGridSection: some View {
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
    
    private var titleTextField: some View { 
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
    
    private var contentTextField: some View {
        LimitedTextField(
            text: $store.content.sending(\.contentChanged),
            isFocused: $isFocused,
            placeholder: "떠오르는 순간을 적어보세요.\n기록은 마음을 정리하는 작은 시작이 될 수 있어요.",
            maxCharacters: 1000
        )
    }
    
    private var saveButton: some View {
        Button {
            saveMemory()
        } label: {
            Text("저장하기")
                .typography(.button)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(store.isSaveButtonEnabled ? Color.pawPrimary : Color.gray40)
                .cornerRadius(14, corners: .allCorners)
        }
        .disabled(!store.isSaveButtonEnabled)
        .padding(.bottom, 20)
    }
    
    // MARK: - Actions
    
    private func saveMemory() {
        let album = MemoryModel(
            title: store.title,
            content: store.content,
            date: Date(),
            images: store.imageGrid.selectedImages
        )
        
        modelContext.insert(album)
        
        do {
            try modelContext.save()
            print("✅ 저장 성공: \(album.title)")
            store.send(.saveButtonTapped)
        } catch {
            print("❌ 저장 실패: \(error)")
        }
    }
    
    // MARK: - Photo Library Permission
    
    private func requestPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                print("📸 사진 권한: \(newStatus)")
            }
        case .authorized, .limited:
            print("✅ 사진 권한 허용됨")
        case .denied, .restricted:
            print("❌ 사진 권한 거부됨")
        @unknown default:
            break
        }
    }
}
