//
//  TermsOfServiceFeature.swift
//  pawrest
//
//  Created by 소은 on 8/12/26.
//

import ComposableArchitecture

struct TermsOfServiceFeature: Reducer {
    
    @ObservableState
    struct State: Equatable {
        var navigationBar: NavigationBarState = NavigationBarState(
            title: "이용약관",
            leftButton: .back,
            rightButton: .none
        )
    }
    
    @CasePathable
    enum Action: Equatable {
        case navigationBar(NavigationBarAction)
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .navigationBar:
            return .none
        }
    }
}
