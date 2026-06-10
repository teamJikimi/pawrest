//
//  MyFeature.swift
//  pawrest
//
//  Created by 소은 on 6/5/26.
//

import ComposableArchitecture

struct MyFeature: Reducer {
    
    // MARK: - State
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
        case path(StackActionOf<Path>)
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
            state.path.append(.blockedList(BlockedListFeature.State()))
            return .none
        case .privacyPolicyTapped:
            state.path.append(.privacyPolicy(PrivacyPolicyFeature.State()))
            return .none
        case .deleteAccountTapped:
            return .none
        case .logoutTapped:
            return .none
        case .navigationBar:
            return .none
        case .path:
            return .none
        }
    }
}
