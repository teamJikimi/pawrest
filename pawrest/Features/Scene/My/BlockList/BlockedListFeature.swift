//
//  BlockedListFeature.swift
//  pawrest
//
//  Created by 소은 on 6/6/26.
//

import ComposableArchitecture

struct BlockedListFeature: Reducer {
    
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var navigationBar: NavigationBarState = NavigationBarState(
            title: "차단 목록",
            leftButton: .back,
            rightButton: .none
        )
    }
    
    // MARK: - Action
    @CasePathable
    enum Action: Equatable {
        case navigationBar(NavigationBarAction)
    }
    
    // MARK: - Reducer
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .navigationBar:
            return .none
        }
    }
}
