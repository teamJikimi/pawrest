//
//  AppFeature.swift
//  pawrest
//
//  Created by 곽예리 on 7/12/26.
//

import ComposableArchitecture

@ObservableState
struct AppState: Equatable {
    enum Destination: Equatable {
        case splash
        case login
        case onboardingUserProfile
        case tabBar
    }

    var destination: Destination = .splash
    var splash = SplashState()
    var login = LoginState()
    var onboardingUserProfile = OnboardingUserProfileState()
    var tabBar = TabBarFeature.State()
}

@CasePathable
enum AppAction {
    case splash(SplashAction)
    case login(LoginAction)
    case onboardingUserProfile(OnboardingUserProfileAction)
    case tabBar(TabBarFeature.Action)
}

struct AppReducer: Reducer {
    var body: some Reducer<AppState, AppAction> {
        Scope(state: \.splash, action: \.splash) {
            SplashReducer()
        }
        Scope(state: \.login, action: \.login) {
            LoginReducer()
        }
        Scope(state: \.onboardingUserProfile, action: \.onboardingUserProfile) {
            OnboardingUserProfileReducer()
        }
        Scope(state: \.tabBar, action: \.tabBar) {
            TabBarFeature()
        }

        Reduce { state, action in
            switch action {
            case .splash(.delegate(.finished)):
                state.destination = .login
                return .none

            case .login(.signInResponse(.success)):
                state.destination = .onboardingUserProfile
                return .none

            case .splash, .login, .onboardingUserProfile, .tabBar:
                return .none
            }
        }
    }
}
