//
//  OnboardingUserProfileView.swift
//  pawrest
//
//  Created by Moon AYoung on 7/11/26.
//

import SwiftUI
import PhotosUI
import ComposableArchitecture

struct OnboardingUserProfileView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<OnboardingUserProfileReducer>
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var showImageActionSheet = false
    @State private var showPhotoPicker = false
    @FocusState private var isFocused: Bool

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                        .padding(.top, 14)

                    Color.clear.frame(height: 45)

                    profileImageSection

                    Color.clear.frame(height: 40)

                    nicknameSection

                    Spacer(minLength: 40)

                    nextButton
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                .frame(minHeight: geo.size.height)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = false
        }
        .customNavigationBar(
            store: store.scope(state: \.navigationBar, action: \.navigationBar)
        )
        .confirmationDialog("프로필 사진", isPresented: $showImageActionSheet) {
            Button("사진 선택") { showPhotoPicker = true }
            if store.profileImage != nil {
                Button("삭제", role: .destructive) {
                    store.send(.profileImageSelected(nil))
                }
            }
            Button("취소", role: .cancel) {}
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectedItem, matching: .images)
        .onChange(of: selectedItem) { _, newItem in
            Task { @MainActor in
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    store.send(.profileImageSelected(data))
                }
            }
        }
    }
}

// MARK: - Subviews

private extension OnboardingUserProfileView {

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .bottom, spacing: 0) {
                Image(.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 26)
                Text("에서 사용할")
                    .typography(.title4)
                    .foregroundColor(.gray90)
            }

            Text("프로필을 만들어요.")
                .typography(.title4)
                .foregroundColor(.gray90)
                .padding(.top, 4)

            OnboardingPagination(totalSteps: 2, currentStep: 0)
                .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var profileImageLabel: some View {
        let clipShape = ProfileClipShape(
            profileSize: 86,
            cutoutSize: 24,
            offset: CGPoint(x: 2, y: 2)
        )
        return ZStack(alignment: .bottomTrailing) {
            Group {
                if let data = store.profileImage,
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(.profileUser)
                        .resizable()
                        .scaledToFit()
                }
            }
            .frame(width: 86, height: 86)
            .clipShape(clipShape)
            .overlay(clipShape.stroke(.gray40, lineWidth: 1))

            Image(.iconImageEdit)
                .resizable()
                .scaledToFit()
                .frame(width: 27, height: 27)
                .offset(x: 3, y: 3)
        }
    }

    var profileImageSection: some View {
        Button {
            if store.profileImage != nil {
                showImageActionSheet = true
            } else {
                showPhotoPicker = true
            }
        } label: {
            profileImageLabel
        }
        .buttonStyle(.plain)
    }

    var nicknameSection: some View {
        OnboardingTextField.withDuplicateCheck(
            placeholder: "닉네임을 입력하세요",
            text: Binding(
                get: { store.nickname },
                set: { store.send(.nicknameChanged($0)) }
            ),
            helper: store.nicknameStatus.helper,
            isButtonEnabled: store.isDuplicateCheckEnabled,
            isFocused: $isFocused,
            onCheck: { store.send(.duplicateCheckTapped) }
        )
    }

    var nextButton: some View {
        Button {
            store.send(.nextTapped)
        } label: {
            Text("다음")
                .typography(.button)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(store.isNextEnabled ? Color.pawPrimary : Color.gray40)
                .cornerRadius(14, corners: .allCorners)
        }
        .disabled(!store.isNextEnabled)
    }
}
