//
//  MyView.swift
//  pawrest
//
//  Created by 소은 on 5/17/26.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

struct MyView: View {
    @Bindable var store: StoreOf<MyFeature>
    @Query private var userProfiles: [UserProfile]
    @Query private var petProfiles: [PetProfile]
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ScrollView {
                VStack(spacing: 12) {
                    petProfileSection
                    notificationSection
                    accountSection
                }
                .padding(20)
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 60)
                }
            }
            .environment(\.font, nil)
            .background(.gray0)
            .customNavigationBar(store: store.scope(state: \.navigationBar, action: \.navigationBar))
            .onAppear {
                if let user = userProfiles.first, let pet = petProfiles.first {
                    store.send(.onAppear(
                        nickname: user.nickname,
                        petName: pet.name,
                        petBirthday: pet.birthday,
                        petDeathDay: pet.deathDay,
                        userImage: user.profileImage,
                        petImage: pet.profileImage
                    ))
                }
            }
        } destination: { (pathStore: StoreOf<MyFeature.Path>) in
            switch pathStore.state {
            case .blockedList(let state):
                BlockedListView(store: Store(initialState: state) {
                    BlockedListFeature()
                })
            case .privacyPolicy(let state):
                PrivacyPolicyView(store: Store(initialState: state) {
                    PrivacyPolicyFeature()
                })
            }
        }
    }
}

// MARK: - Subviews
private extension MyView {
    
    var petProfileSection: some View {
        VStack(spacing: 12) {
            userHeader
            petProfileCard
        }
    }
    
    var userHeader: some View {
        HStack(spacing: 8) {
            Group {
                if let data = store.user.userImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(.profileSmall)
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(.gray20, lineWidth: 1)
            )
            
            Text(store.user.userName)
                .typography(.body1Accent)
                .foregroundStyle(.gray80)
            
            Spacer()
            
            Button {
                store.send(.profileEditTapped)
            } label: {
                Text("프로필 수정")
                    .typography(.caption)
                    .foregroundStyle(.pawPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.pawPrimary, lineWidth: 0.5)
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var petProfileCard: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray10, lineWidth: 1)
                )
            
            VStack {
                Image(.imageCheckPattern)
                    .resizable()
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .clipped()
                Spacer()
            }
            .cornerRadius(20, corners: [.topLeft, .topRight])
            
            VStack(alignment: .leading, spacing: 6) {
                Text(store.user.petName)
                    .typography(.pageTitle)
                    .foregroundStyle(.gray80)
                
                HStack(spacing: 4) {
                    Image(.imageGrayCalendar)
                        .resizable()
                        .frame(width: 10, height: 10)
                    
                    Text("\(store.user.petBirthDate) - \(store.user.petDeathDate)")
                        .typography(.body2R1)
                        .foregroundStyle(.gray50)
                }
            }
            .padding(.top, 40 + 12)
            .padding(.leading, 16 + 88 + 12)
            .padding(.bottom, 34)
            
            petThumbnail
                .offset(x: 16, y: 5)
                .padding(.top, 16)
        }
    }
    
    var petThumbnail: some View {
        Group {
            if let data = store.user.petImageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(.profileLarge)
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: 88, height: 88)
        .clipShape(Circle())
        .background(
            Circle()
                .fill(Color.white)
                .frame(width: 98, height: 98)
        )
        .overlay(
            Circle()
                .stroke(.primaryLight, lineWidth: 1)
                .frame(width: 98, height: 98)
        )
    }
    
    var notificationSection: some View {
        NotificationSettingsView(
            emotionReminder: $store.isEmotionReminderOn.sending(\.emotionReminderToggled),
            weeklyReport: $store.isWeeklyReportOn.sending(\.weeklyReportToggled),
            petMemory: $store.isDailyRecordOn.sending(\.dailyRecordToggled),
            communityReaction: $store.isCommunityReactionOn.sending(\.communityReactionToggled)
        )
    }
    
    var accountSection: some View {
        AccountSettingsView(
            onBlockedList: { store.send(.blockedListTapped) },
            onPrivacyPolicy: { store.send(.privacyPolicyTapped) },
            onDeleteAccount: { store.send(.deleteAccountTapped) },
            onLogout: { store.send(.logoutTapped) }
        )
    }
}
