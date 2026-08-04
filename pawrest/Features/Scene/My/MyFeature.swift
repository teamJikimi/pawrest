//
//  MyFeature.swift
//  pawrest
//
//  Created by 소은 on 6/5/26.
//

import Foundation
import ComposableArchitecture
import SwiftData

struct MyFeature: Reducer {
    
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var user: MyModel = .mock
        
        var isEmotionReminderOn: Bool = false
        var isWeeklyReportOn: Bool = false
        var isDailyRecordOn: Bool = true
        var isCommunityReactionOn: Bool = true
        
        var showLogoutAlert: Bool = false
        var showDeleteAccountAlert: Bool = false
        
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
            case blockedList(BlockedListFeature.State)
            case privacyPolicy(PrivacyPolicyFeature.State)
        }
        
        @CasePathable
        enum Action {
            case blockedList(BlockedListFeature.Action)
            case privacyPolicy(PrivacyPolicyFeature.Action)
        }
        
        func reduce(into state: inout State, action: Action) -> Effect<Action> {
            switch action {
            case .blockedList(let action):
                guard case .blockedList(var blockedState) = state else { return .none }
                let effect = BlockedListFeature().reduce(into: &blockedState, action: action)
                state = .blockedList(blockedState)
                return effect.map(Action.blockedList)
            case .privacyPolicy(let action):
                guard case .privacyPolicy(var privacyState) = state else { return .none }
                let effect = PrivacyPolicyFeature().reduce(into: &privacyState, action: action)
                state = .privacyPolicy(privacyState)
                return effect.map(Action.privacyPolicy)
            }
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
        case deleteAccountTapped
        case deleteAccountAlertDismissed
        case deleteAccountConfirmed
        case logoutTapped
        case logoutAlertDismissed
        case logoutConfirmed
        case navigationBar(NavigationBarAction)
        case path(StackActionOf<Path>)
    }

    // MARK: - Reducer
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
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
            return .none
        case .emotionReminderToggled(let value):
            state.isEmotionReminderOn = value
            UserDefaults.standard.set(value, forKey: "emotionReminderEnabled")
            NotificationService.shared.scheduleEmotionReminders(enabled: value)
            return .none
        case .weeklyReportToggled(let value):
            state.isWeeklyReportOn = value
            return .none
        case .dailyRecordToggled(let value):
            state.isDailyRecordOn = value
            return .none
        case .communityReactionToggled(let value):
            state.isCommunityReactionOn = value
            return .none
        case .blockedListTapped:
            state.path.append(.blockedList(BlockedListFeature.State()))
            return .none
        case .privacyPolicyTapped:
            state.path.append(.privacyPolicy(PrivacyPolicyFeature.State()))
            return .none
        case .deleteAccountTapped:
            state.showDeleteAccountAlert = true
            return .none
        case .deleteAccountAlertDismissed:
            state.showDeleteAccountAlert = false
            return .none
        case .deleteAccountConfirmed:
            state.showDeleteAccountAlert = false
            return .none
        case .logoutTapped:
            state.showLogoutAlert = true
            return .none
        case .logoutAlertDismissed:
            state.showLogoutAlert = false
            return .none
        case .logoutConfirmed:
            state.showLogoutAlert = false
            return .none
        case .navigationBar:
            return .none
        case .path:
            return .none
        }
    }
}
