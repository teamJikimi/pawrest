//
//  MyFeature.swift
//  pawrest
//
//  Created by 소은 on 6/5/26.
//

import Foundation
import ComposableArchitecture
import FirebaseAuth

struct MyFeature: Reducer {

    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var user: MyModel = .mock

        var isEmotionReminderOn: Bool = UserDefaults.standard.bool(forKey: "emotionReminderEnabled")
        var isWeeklyReportOn: Bool = UserDefaults.standard.bool(forKey: "weeklyReportEnabled")
        var isDailyRecordOn: Bool = UserDefaults.standard.object(forKey: "dailyRecordEnabled") as? Bool ?? true
        var isCommunityReactionOn: Bool = UserDefaults.standard.object(forKey: "communityReactionEnabled") as? Bool ?? true

        var showLogoutAlert: Bool = false
        var showDeleteAccountAlert: Bool = false
        var isShowingSubPage: Bool = false

        var navigationBar: NavigationBarState = NavigationBarState(
            title: "마이",
            leftButton: .none,
            rightButton: .none
        )

        var path: StackState<Path.State> = .init()
    }

    // MARK: - Path
    struct Path: Reducer {
        @CasePathable
        @ObservableState
        enum State: Equatable {
            case profileEdit(ProfileEditFeature.State)
            case blockedList(BlockedListFeature.State)
            case privacyPolicy(PrivacyPolicyFeature.State)
            case termsOfService(TermsOfServiceFeature.State)
        }

        @CasePathable
        enum Action {
            case profileEdit(ProfileEditFeature.Action)
            case blockedList(BlockedListFeature.Action)
            case privacyPolicy(PrivacyPolicyFeature.Action)
            case termsOfService(TermsOfServiceFeature.Action)
        }

        var body: some Reducer<State, Action> {
            Reduce { _, _ in .none }
                .ifCaseLet(\.profileEdit, action: \.profileEdit) { ProfileEditFeature() }
                .ifCaseLet(\.blockedList, action: \.blockedList) { BlockedListFeature() }
                .ifCaseLet(\.privacyPolicy, action: \.privacyPolicy) { PrivacyPolicyFeature() }
                .ifCaseLet(\.termsOfService, action: \.termsOfService) { TermsOfServiceFeature() }
        }
    }

    // MARK: - Action
    @CasePathable
    enum Action {
        case onAppear(nickname: String, petName: String, petBirthday: Date?, petDeathDay: Date?, userImage: Data?, petImage: Data?)
        case profileEditTapped
        case emotionReminderToggled(Bool)
        case weeklyReportToggled(Bool)
        case dailyRecordToggled(Bool)
        case communityReactionToggled(Bool)
        case blockedListTapped
        case privacyPolicyTapped
        case termsOfServiceTapped
        case logoutTapped
        case logoutAlertDismissed
        case logoutConfirmed
        case deleteAccountTapped
        case deleteAccountAlertDismissed
        case deleteAccountConfirmed
        case subPageDismissed
        case navigationBar(NavigationBarAction)
        case path(StackActionOf<Path>)
    }

    // MARK: - Body
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .onAppear(nickname, petName, petBirthday, petDeathDay, userImage, petImage):
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy.MM.dd"
                let birthStr = petBirthday.map { formatter.string(from: $0) } ?? "-"
                let deathStr = petDeathDay.map { formatter.string(from: $0) } ?? "-"
                state.user = MyModel(
                    userName: nickname,
                    petName: petName,
                    petBirthDate: birthStr,
                    petDeathDate: deathStr,
                    userImageData: userImage,
                    petImageData: petImage
                )
                return .none

            case .profileEditTapped:
                state.path.append(.profileEdit(ProfileEditFeature.State()))
                state.isShowingSubPage = true
                return .none

            case .emotionReminderToggled(let value):
                state.isEmotionReminderOn = value
                UserDefaults.standard.set(value, forKey: "emotionReminderEnabled")
                NotificationService.shared.scheduleEmotionReminders(enabled: value)
                return .none

            case .weeklyReportToggled(let value):
                state.isWeeklyReportOn = value
                UserDefaults.standard.set(value, forKey: "weeklyReportEnabled")
                return .none

            case .dailyRecordToggled(let value):
                state.isDailyRecordOn = value
                UserDefaults.standard.set(value, forKey: "dailyRecordEnabled")
                return .none

            case .communityReactionToggled(let value):
                state.isCommunityReactionOn = value
                UserDefaults.standard.set(value, forKey: "communityReactionEnabled")
                return .none

            case .blockedListTapped:
                state.path.append(.blockedList(BlockedListFeature.State()))
                state.isShowingSubPage = true
                return .none

            case .privacyPolicyTapped:
                state.path.append(.privacyPolicy(PrivacyPolicyFeature.State()))
                state.isShowingSubPage = true
                return .none

            case .termsOfServiceTapped:
                state.path.append(.termsOfService(TermsOfServiceFeature.State()))
                state.isShowingSubPage = true
                return .none

            case .logoutTapped:
                state.showLogoutAlert = true
                return .none

            case .logoutAlertDismissed:
                state.showLogoutAlert = false
                return .none

            case .logoutConfirmed:
                state.showLogoutAlert = false
                return .run { _ in
                    try? Auth.auth().signOut()
                }

            case .deleteAccountTapped:
                state.showDeleteAccountAlert = true
                return .none

            case .deleteAccountAlertDismissed:
                state.showDeleteAccountAlert = false
                return .none

            case .deleteAccountConfirmed:
                state.showDeleteAccountAlert = false
                return .run { _ in
                    try? await Auth.auth().currentUser?.delete()
                }

            case .subPageDismissed:
                state.isShowingSubPage = false
                return .none

            case .navigationBar:
                return .none

            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path) {
            Path()
        }
    }
}
