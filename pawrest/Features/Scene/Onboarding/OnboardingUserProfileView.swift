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
    @FocusState private var isFocused: Bool

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            headerSection
                .padding(.top, 35)

            Color.clear.frame(height: 45)

            profileImageSection

            Color.clear.frame(height: 40)

            nicknameSection

            Spacer()

            nextButton
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = false
        }
        .customNavigationBar(
            store: store.scope(state: \.navigationBar, action: \.navigationBar)
        )
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
        PhotosPicker(selection: $selectedItem, matching: .images) {
            profileImageLabel
        }
        .onChange(of: selectedItem) { _, newItem in
            Task { @MainActor in
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    store.send(.profileImageSelected(data))
                }
            }
        }
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

#Preview {
    NavigationStack {
        OnboardingUserProfileView(
            store: Store(
                initialState: OnboardingUserProfileState()
            ) {
                OnboardingUserProfileReducer()
            }
        )
    }
}
