//
//  TabBarFeature.swift
//  pawrest
//
//  Created by 소은 on 5/17/26.
//

import ComposableArchitecture

struct TabBarFeature: Reducer {

    @ObservableState
    struct State: Equatable {
        var selectedTab: Tab = .home
        var my: MyFeature.State = .init()

        enum Tab: Int, CaseIterable {
            case home = 0
            case memorial = 1
            case memory = 2
            case community = 3
            case my = 4

            var title: String {
                switch self {
                case .home: return "홈"
                case .memorial: return "추모"
                case .memory: return "추억"
                case .community: return "커뮤니티"
                case .my: return "마이"
                }
            }

            var iconName: String {
                switch self {
                case .home: return "home"
                case .memorial: return "memorial"
                case .memory: return "memory"
                case .community: return "community"
                case .my: return "my"
                }
            }

            var iconNameFill: String {
                return iconName + "_fill"
            }
        }
    }

    @CasePathable
    enum Action {
        case tabSelected(State.Tab)
        case my(MyFeature.Action)
        case delegate(Delegate)

        enum Delegate: Equatable {
            case logoutCompleted
            case deleteAccountCompleted
        }
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.my, action: \.my) {
            MyFeature()
        }
        Reduce { state, action in
            switch action {
            case .tabSelected(let tab):
                state.selectedTab = tab
                return .none
            case .my(.logoutConfirmed):
                return .send(.delegate(.logoutCompleted))
            case .my(.deleteAccountConfirmed):
                return .send(.delegate(.deleteAccountCompleted))
            case .my, .delegate:
                return .none
            }
        }
    }
}
