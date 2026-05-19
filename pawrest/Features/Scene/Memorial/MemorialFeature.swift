//
//  MemorialFeature.swift
//  pawrest
//
//  Created by 소은 on 5/20/26.
//

import ComposableArchitecture

// MARK: - State

@ObservableState
struct MemorialState: Equatable {
    var navigationBar = NavigationBarState(
        title: "게시글",
        leftButton: .back,
        rightButton: .reportMenu
    )
}

// MARK: - Action

@CasePathable
enum MemorialAction: Equatable {
    case navigationBar(NavigationBarAction)
}

// MARK: - Reducer

struct MemorialReducer: Reducer {
    var body: some Reducer<MemorialState, MemorialAction> {
        Scope(state: \.navigationBar, action: \.navigationBar) {
            NavigationBarReducer()
        }
        
        Reduce { state, action in
            switch action {
            case .navigationBar(.leftButtonTapped):
                print("뒤로가기")
                return .none
                
            case .navigationBar(.reportBoardSettings):
                print("게시판 설정")
                return .none
                
            case .navigationBar(.reportAbuse):
                print("욕설/비하")
                return .none
                
            case .navigationBar(.reportSpam):
                print("스팸")
                return .none
                
            case .navigationBar(.blockTapped):
                print("차단")
                return .none
                
            case .navigationBar:
                return .none
            }
        }
    }
}
