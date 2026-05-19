//
//  HomeFeature.swift
//  pawrest
//
//  Created by 소은 on 5/17/26.
//

import ComposableArchitecture

struct HomeFeature: Reducer {
    
    // MARK: - State
    
    @ObservableState
    struct State: Equatable {
    }
    
    // MARK: - Action
    
    enum Action {
        case onAppear
        case addButtonTapped
    }
    
    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .onAppear:
            return .none
        case .addButtonTapped:
            return .none
        }
    }
}
