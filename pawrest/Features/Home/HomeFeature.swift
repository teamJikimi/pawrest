//
//  HomeFeature.swift
//  pawrest
//

import ComposableArchitecture

struct HomeFeature: Reducer {
    
    @ObservableState
    struct State: Equatable {
        var count: Int = 0
        var text: String = "홈 화면"
    }
    
    enum Action {
        case incrementButtonTapped
        case decrementButtonTapped
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .incrementButtonTapped:
            state.count += 1
            return .none
            
        case .decrementButtonTapped:
            state.count -= 1
            return .none
        }
    }
}
