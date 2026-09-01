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

    // MARK: - Properties

    @Bindable var store: StoreOf<OnboardingIntroduceReducer>
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Color.clear.frame(height: 40)
                
                imageSection(availableHeight: geometry.size.height)
                
                Color.clear.frame(height: 8)
                
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
                    .padding(.top, 80)
            }
        }
        .padding(.horizontal, 20)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .animation(.easeInOut(duration: 0.3), value: store.currentPage)
    }
}

// MARK: - Subviews

private extension OnboardingIntroduceView {
    
    func imageSection(availableHeight: CGFloat) -> some View {
        Image(store.currentPageData.imageAsset)
            .resizable()
            .scaledToFit()
            .frame(height: availableHeight * 0.50, alignment: .bottom) 
            .offset(y:8)
            .id(store.currentPage)
            .transition(.opacity)
    }
    
    var textSection: some View {
        VStack(spacing: 16) {
            highlightedTitle(store.currentPageData.titleParts)
            
            if let subtitle = store.currentPageData.subtitle {
                Text(subtitle)
                    .font(.system(size: 16, weight: .regular))
                    .tracking(-0.28)
                    .lineSpacing(4)
                    .foregroundColor(.gray70)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    func highlightedTitle(_ parts: [TitlePart]) -> some View {
        var attributed = AttributedString()
        for part in parts {
            var segment = AttributedString(part.text)
            segment.foregroundColor = part.isHighlighted ? Color.pawPrimary : Color.gray90
            attributed.append(segment)
        }
        return Text(attributed)
            .font(.system(size: 22, weight: .bold))
            .tracking(-0.4)
            .lineSpacing(3)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
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
                .padding(.vertical, 16)
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

        if let deathDay = store.petDeathDay {
            NotificationService.shared.scheduleAnniversaryReminder(
                petName: store.petName,
                anniversaryDate: deathDay,
                enabled: true
            )
        }

        store.send(.saveCompleted)
    }

    func secondaryButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .typography(.button)
                .foregroundColor(.gray60)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(.gray10)
                .cornerRadius(14, corners: .allCorners)
        }
    }
}
