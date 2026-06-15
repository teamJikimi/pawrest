//
//  AlarmFeature.swift
//  pawrest
//
//  Created by 소은 on 6/12/26.
//

import ComposableArchitecture

struct AlarmFeature: Reducer {
    @ObservableState
    struct State: Equatable {}

    @CasePathable
    enum Action: Equatable {
        case onAppear
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .onAppear:
            return .none
        }
    }
}
