//
//  MyView.swift
//  pawrest
//
//  Created by 소은 on 5/17/26.
//

import SwiftUI
import SwiftData
import FirebaseAuth
import ComposableArchitecture

struct MyView: View {
    @Bindable var store: StoreOf<MyFeature>
    @Query private var userProfiles: [UserProfile]
    @Query private var petProfiles: [PetProfile]
    @Environment(\.modelContext) private var modelContext
    
    var onLogoutCompleted: () -> Void = {}

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ScrollView {
                VStack(spacing: 16) {
                    petProfileSection
                    notificationSection
                    accountSection
                }
                .padding(20)
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 60)
                }
            }
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
            .alert("로그아웃", isPresented: Binding(
                get: { store.showLogoutAlert },
                set: { if !$0 { store.send(.logoutAlertDismissed) } }
            )) {
                Button("취소", role: .cancel) {
                    store.send(.logoutAlertDismissed)
                }
                Button("로그아웃", role: .destructive) {
                    store.send(.logoutConfirmed)
                    onLogoutCompleted()
                }
            } message: {
                Text("로그아웃 하시겠습니까?")
            }
            .alert("회원탈퇴", isPresented: Binding(
                get: { store.showDeleteAccountAlert },
                set: { if !$0 { store.send(.deleteAccountAlertDismissed) } }
            )) {
                Button("취소", role: .cancel) {
                    store.send(.deleteAccountAlertDismissed)
                }
                Button("탈퇴하기", role: .destructive) {
                    try? modelContext.delete(model: UserProfile.self)
                    try? modelContext.delete(model: PetProfile.self)
                    try? modelContext.delete(model: EmotionRecordModel.self)
                    try? modelContext.delete(model: AssessmentRecord.self)
                    try? modelContext.delete(model: MemoryModel.self)
                    try? modelContext.delete(model: LetterModel.self)
                    try? modelContext.delete(model: NotificationRecord.self)
                    store.send(.deleteAccountConfirmed)
                    onLogoutCompleted()
                }
            } message: {
                Text("탈퇴하면 모든 데이터가 삭제되며\n복구할 수 없습니다. 탈퇴하시겠습니까?")
            }
        } destination: { (pathStore: StoreOf<MyFeature.Path>) in
            switch pathStore.state {
            case .profileEdit(let state):
                ProfileEditView(store: Store(initialState: state) {
                    ProfileEditFeature()
                })
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
        .onChange(of: store.path.count) { _, count in
            if count == 0 {
                store.send(.subPageDismissed)
            }
        }
    }
}

// MARK: - Subviews
private extension MyView {
    
    var petProfileSection: some View {
        VStack(spacing: 8) {
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
                    Image(.profileUser)
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(width: 32, height: 32)
            .clipShape(Circle())
            
            Text(store.user.userName)
                .typography(.body2Accent)
                .foregroundStyle(.gray80)
            
            Spacer()
            
            Button {
                store.send(.profileEditTapped)
            } label: {
                Text("프로필 수정")
                    .typography(.date)
                    .foregroundStyle(.pawPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.pawPrimary, lineWidth: 0.5)
                    )
            }
        }
        .padding(.vertical, 12)
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
                    .typography(.body1Accent)
                    .foregroundStyle(.gray80)
                
                HStack(spacing: 4) {
                    Image(.imageGrayCalendar)
                        .resizable()
                        .frame(width: 10, height: 10)
                    
                    Text("\(store.user.petBirthDate) - \(store.user.petDeathDate)")
                        .typography(.date)
                        .foregroundStyle(.gray50)
                }
            }
            .padding(.top, 40 + 12)
            .padding(.leading, 16 + 86 + 12)
            .padding(.bottom, 34)
            
            petThumbnail
                .offset(x: 16, y: 40 - 30)
        }
        .padding(.vertical, 8)
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
        .frame(width: 86, height: 86)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.white, lineWidth: 5)
        )
        .overlay(
            Circle()
                .stroke(.primaryLight, lineWidth: 1)
                .padding(-5)
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
