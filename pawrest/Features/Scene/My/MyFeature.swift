//
//  MyFeature.swift
//  pawrest
//
//  Created by 소은 on 6/5/26.
//

import ComposableArchitecture

struct MyFeature: Reducer {
    
    @ObservableState
    struct State: Equatable {
        var user: MyModel = .mock
        
        var isEmotionReminderOn: Bool = false
        var isWeeklyReportOn: Bool = false
        var isDailyRecordOn: Bool = true
        var isCommunityReactionOn: Bool = true
        
        var navigationBar: NavigationBarState = NavigationBarState(
            title: "마이",
            leftButton: .none,
            rightButton: .none
        )
    }
    
    // MARK: - Action
    @CasePathable
    enum Action: Equatable {
        case profileEditTapped
        case emotionReminderToggled(Bool)
        case weeklyReportToggled(Bool)
        case dailyRecordToggled(Bool)
        case communityReactionToggled(Bool)
        case blockedListTapped
        case privacyPolicyTapped
        case deleteAccountTapped
        case logoutTapped
        case navigationBar(NavigationBarAction)
    }
    
    // MARK: - Reducer
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .profileEditTapped:
            return .none
        case .emotionReminderToggled(let value):
            state.isEmotionReminderOn = value
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
            return .none
        case .privacyPolicyTapped:
            return .none
        case .deleteAccountTapped:
            return .none
        case .logoutTapped:
            return .none
        case .navigationBar:
            return .none
        }
    }
}
