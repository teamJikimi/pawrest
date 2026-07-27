//
//  AppView.swift
//  pawrest
//
//  Created by 곽예리 on 7/12/26.
//

import SwiftUI
import ComposableArchitecture

struct AppView: View {
    @Bindable var store: StoreOf<AppReducer>

    var body: some View {
        switch store.destination {
        case .splash:
            SplashView(store: store.scope(state: \.splash, action: \.splash))
        case .login:
            LoginView(store: store.scope(state: \.login, action: \.login))
        case .onboardingUserProfile:
            OnboardingUserProfileView(store: store.scope(state: \.onboardingUserProfile, action: \.onboardingUserProfile))
        case .onboardingPetProfile:
            OnboardingPetProfileView(store: store.scope(state: \.onboardingPetProfile, action: \.onboardingPetProfile))
        case .onboardingIntroduce:
            OnboardingIntroduceView(store: store.scope(state: \.onboardingIntroduce, action: \.onboardingIntroduce))
        case .tabBar:
            TabBarView(store: store.scope(state: \.tabBar, action: \.tabBar))
        }
    }
}
