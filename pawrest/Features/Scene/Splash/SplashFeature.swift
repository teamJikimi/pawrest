//
//  SplashFeature.swift
//  pawrest
//
//  Created by 곽예리 on 7/12/26.
//

import Foundation
import ComposableArchitecture

// MARK: - State

@ObservableState
struct SplashState: Equatable {}

// MARK: - Action

@CasePathable
enum SplashAction: Equatable {
    case onAppear
    case delegate(Delegate)

    @CasePathable
    enum Delegate: Equatable {
        case finished
    }
}

// MARK: - Reducer

struct SplashReducer: Reducer {
    var body: some Reducer<SplashState, SplashAction> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    try await Task.sleep(for: .seconds(2))
                    await send(.delegate(.finished))
                }

            case .delegate:
                return .none
            }
        }
    }
}

