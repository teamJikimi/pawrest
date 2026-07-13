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
        .customNavigationBar(
            store: store.scope(state: \.navigationBar, action: \.navigationBar)
        )

        //스데 임시 연결
        .navigationDestination(
            isPresented: Binding(
                get: { store.isPetProfilePresented },
                set: { if !$0 { store.send(.petProfileDismissed) } }
            )
        ) {
            OnboardingPetProfileView(
                store: Store(
                    initialState: OnboardingPetProfileState(
                        nickname: store.nickname,
                        userProfileImage: store.profileImage
                    ),
                    reducer: { OnboardingPetProfileReducer() }
                )
            )
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
    
    var profileImageSection: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images
        ) {
            ZStack(alignment: .center) {
                if let data = store.profileImage,
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 86, height: 86)
                        .clipShape(Circle())
                } else {
                    Image(.profileUser)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 86, height: 86)
                }
            }
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
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
            onCheck: { store.send(.duplicateCheckTapped) }
        )
    }
    
    var nextButton: some View {
        Button {
            store.send(.nextTapped)
        } label: {
            Text("다음")
                .typography(.button)
                .foregroundColor(.gray0)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(store.isNextEnabled ? .pawPrimary : .gray40)
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
