//
//  TabBarFeature.swift
//  pawrest
//
//  Created by 소은 on 5/17/26.
//

import ComposableArchitecture

struct TabBarFeature: Reducer {
    
    @ObservableState
    public struct State: Equatable {
        var selectedTab: Tab = .home
        var isTabBarHidden: Bool = false
        
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
    
    enum Action {
        case tabSelected(State.Tab)
        case setTabBarHidden(Bool)
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .tabSelected(let tab):
            state.selectedTab = tab
            return .none
        case .setTabBarHidden(let hidden):
            state.isTabBarHidden = hidden
            return .none
        }
    }
}
