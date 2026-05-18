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
        // 필요한 상태 추가
    }
    
    // MARK: - Action
    
    enum Action {
        case onAppear
    }
    
    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .onAppear:
            return .none
        }
    }
}
