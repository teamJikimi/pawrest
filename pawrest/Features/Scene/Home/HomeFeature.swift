//
//  HomeFeature.swift
//  pawrest
//
//  Created by 소은 on 5/17/26.
//

import ComposableArchitecture

struct HomeFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var emotionCheckIn = EmotionCheckInFeature.State()
        var recommendedContent = RecommendedContentFeature.State()
        var recentRecord = RecentRecordFeature.State()
        var isAlarmPresented: Bool = false
        var navigationBar = NavigationBarState(
            title: "",
            leftButton: .logo,
            rightButton: .alarm
        )
    }

    @CasePathable
    enum Action {
        case onAppear
        case addButtonTapped
        case emotionCheckIn(EmotionCheckInFeature.Action)
        case recommendedContent(RecommendedContentFeature.Action)
        case recentRecord(RecentRecordFeature.Action)
        case navigationBar(NavigationBarAction)
    }

    private let emotionCheckInReducer = EmotionCheckInFeature()
    private let recommendedContentReducer = RecommendedContentFeature()
    private let recentRecordReducer = RecentRecordFeature()

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .onAppear:
            return .none
        case .addButtonTapped:
            return .none
        case .navigationBar(.alarmTapped):
            state.isAlarmPresented = true
            return .none
        case .navigationBar:
            return .none
        case .emotionCheckIn(let emotionAction):
            return emotionCheckInReducer
                .reduce(into: &state.emotionCheckIn, action: emotionAction)
                .map(Action.emotionCheckIn)
        case .recommendedContent(let contentAction):
            return recommendedContentReducer
                .reduce(into: &state.recommendedContent, action: contentAction)
                .map(Action.recommendedContent)
        case .recentRecord(let recordAction):
            return recentRecordReducer
                .reduce(into: &state.recentRecord, action: recordAction)
                .map(Action.recentRecord)
        }
    }
}


//struct HomeFeature: Reducer {
//    @ObservableState
//    struct State: Equatable {
//        var emotionCheckIn = EmotionCheckInFeature.State()
//        var recentRecord = RecentRecordFeature.State()
//        var isAlarmPresented: Bool = false
//        var navigationBar = NavigationBarState(
//            title: "",
//            leftButton: .logo,
//            rightButton: .alarm
//        )
//    }
//
//    @CasePathable
//    enum Action {
//        case onAppear
//        case addButtonTapped
//        case emotionCheckIn(EmotionCheckInFeature.Action)
//        case recentRecord(RecentRecordFeature.Action)
//        case navigationBar(NavigationBarAction)
//    }
//
//    private let emotionCheckInReducer = EmotionCheckInFeature()
//    private let recentRecordReducer = RecentRecordFeature()
//
//    func reduce(into state: inout State, action: Action) -> Effect<Action> {
//        switch action {
//        case .onAppear:
//            return .none
//        case .addButtonTapped:
//            return .none
//        case .navigationBar(.alarmTapped):
//            state.isAlarmPresented = true
//            return .none
//        case .navigationBar:
//            return .none
//        case .emotionCheckIn(let emotionAction):
//            return emotionCheckInReducer
//                .reduce(into: &state.emotionCheckIn, action: emotionAction)
//                .map(Action.emotionCheckIn)
//        case .recentRecord(let recordAction):
//            return recentRecordReducer
//                .reduce(into: &state.recentRecord, action: recordAction)
//                .map(Action.recentRecord)
//        }
//    }
//}
