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
        case onboardingPetProfile
        case onboardingIntroduce
        case tabBar
    }

    var destination: Destination = .splash
    var splash = SplashState()
    var login = LoginState()
    var onboardingUserProfile = OnboardingUserProfileState()
    var onboardingPetProfile = OnboardingPetProfileState(nickname: "", userProfileImage: nil)
    var onboardingIntroduce = OnboardingIntroduceState(
        nickname: "",
        petName: "",
        userProfileImage: nil,
        petProfileImage: nil,
        petBirthday: nil,
        petDeathDay: nil
    )
    var tabBar = TabBarFeature.State()
}

@CasePathable
enum AppAction {
    case splash(SplashAction)
    case login(LoginAction)
    case onboardingUserProfile(OnboardingUserProfileAction)
    case onboardingPetProfile(OnboardingPetProfileAction)
    case onboardingIntroduce(OnboardingIntroduceAction)
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
        Scope(state: \.onboardingPetProfile, action: \.onboardingPetProfile) {
            OnboardingPetProfileReducer()
        }
        Scope(state: \.onboardingIntroduce, action: \.onboardingIntroduce) {
            OnboardingIntroduceReducer()
        }
        Scope(state: \.tabBar, action: \.tabBar) {
            TabBarFeature()
        }

        Reduce { state, action in
            switch action {
            case .splash(.delegate(.finished)):
                state.destination = .login
                return .none

            case .splash(.delegate(.alreadyOnboarded)):
                state.destination = .tabBar
                return .none

            case .login(.signInResponse(.success)):
                state.destination = .onboardingUserProfile
                return .none

            case .onboardingUserProfile(.nextTapped):
                state.onboardingPetProfile = OnboardingPetProfileState(
                    nickname: state.onboardingUserProfile.nickname,
                    userProfileImage: state.onboardingUserProfile.profileImage
                )
                state.destination = .onboardingPetProfile
                return .none

            case .onboardingPetProfile(.nextTapped):
                state.onboardingIntroduce = OnboardingIntroduceState(
                    nickname: state.onboardingUserProfile.nickname,
                    petName: state.onboardingPetProfile.petName,
                    userProfileImage: state.onboardingUserProfile.profileImage,
                    petProfileImage: state.onboardingPetProfile.profileImage,
                    petBirthday: state.onboardingPetProfile.birthday,
                    petDeathDay: state.onboardingPetProfile.deathDay
                )
                state.destination = .onboardingIntroduce
                return .none

            case .onboardingPetProfile(.navigationBar(.leftButtonTapped)):
                state.destination = .onboardingUserProfile
                return .none

            case .onboardingIntroduce(.saveCompleted):
                state.destination = .tabBar
                return .none

            case .splash, .login, .onboardingUserProfile, .onboardingPetProfile, .onboardingIntroduce, .tabBar:
                return .none
            }
        }
    }
}
