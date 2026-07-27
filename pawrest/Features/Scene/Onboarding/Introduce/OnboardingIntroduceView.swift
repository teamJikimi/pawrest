//
//  OnboardingIntroduceView.swift
//  pawrest
//
//  Created by Moon AYoung on 7/13/26.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

struct OnboardingIntroduceView: View {

    @Bindable var store: StoreOf<OnboardingIntroduceReducer>
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            imageSection
            
            Color.clear.frame(height: 56)
            
            textSection
            
            if store.showPagination {
                Color.clear.frame(height: 36)
                OnboardingPagination(
                    totalSteps: 4,
                    currentStep: store.currentPage - 1,
                    style: .introduce
                )
            }
            
            Spacer()
            
            buttonSection
                .padding(.bottom, 40)
        }
        .padding(.horizontal, 20)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .animation(.easeInOut(duration: 0.3), value: store.currentPage)
    }
}

// MARK: - Subviews

private extension OnboardingIntroduceView {
    
    var imageSection: some View {
        Image(store.currentPageData.imageAsset)
            .resizable()
            .scaledToFit()
            .frame(height: 196)
            .id(store.currentPage)
            .transition(.opacity)
    }
    
    var textSection: some View {
        VStack(spacing: 12) {
            highlightedTitle(store.currentPageData.titleParts)
            
            if let subtitle = store.currentPageData.subtitle {
                Text(subtitle)
                    .typography(.body1R)
                    .foregroundColor(.gray70)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    func highlightedTitle(_ parts: [TitlePart]) -> some View {
        parts.reduce(Text("")) { result, part in
            result + Text(part.text)
                .foregroundColor(part.isHighlighted ? .pawPrimary : .gray90)
        }
        .typography(.title4)
        .multilineTextAlignment(.center)
    }
    
    @ViewBuilder
    var buttonSection: some View {
        switch store.currentPageData.buttonStyle {
        case .single(let title):
            primaryButton(title) {
                store.send(.nextTapped)
            }
        case .dual:
            HStack(spacing: 9) {
                secondaryButton("이전") {
                    store.send(.previousTapped)
                }
                primaryButton("다음") {
                    if store.isLastPage {
                        saveAndFinish()
                    } else {
                        store.send(.nextTapped)
                    }
                }
            }
        }
    }
    
    func primaryButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .typography(.button)
                .foregroundColor(.gray0)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(.pawPrimary)
                .cornerRadius(14, corners: .allCorners)
        }
    }

    func saveAndFinish() {
        let user = UserProfile(nickname: store.nickname, profileImage: store.userProfileImage)
        let pet = PetProfile(
            name: store.petName,
            profileImage: store.petProfileImage,
            birthday: store.petBirthday,
            deathDay: store.petDeathDay
        )
        modelContext.insert(user)
        modelContext.insert(pet)
        try? modelContext.save()
        store.send(.saveCompleted)
    }

    func secondaryButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .typography(.button)
                .foregroundColor(.gray60)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(.gray10)
                .cornerRadius(14, corners: .allCorners)
        }
    }
}
