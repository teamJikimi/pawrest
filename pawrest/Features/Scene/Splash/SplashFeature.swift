//
//  SplashFeature.swift
//  pawrest
//
//  Created by 곽예리 on 7/12/26.
//

import Foundation
import ComposableArchitecture

@ObservableState
struct SplashState: Equatable {}

@CasePathable
enum SplashAction: Equatable {
    case onAppear
    case delegate(Delegate)

    @CasePathable
    enum Delegate: Equatable {
        case finished
        case alreadyOnboarded
    }
}

struct SplashReducer: Reducer {
    var body: some Reducer<SplashState, SplashAction> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    try await Task.sleep(for: .seconds(2))
                    let isOnboarded = UserDefaults.standard.bool(forKey: "isOnboardingComplete")
                    if isOnboarded {
                        await send(.delegate(.alreadyOnboarded))
                    } else {
                        await send(.delegate(.finished))
                    }
                }

            case .delegate:
                return .none
            }
        }
    }
}
