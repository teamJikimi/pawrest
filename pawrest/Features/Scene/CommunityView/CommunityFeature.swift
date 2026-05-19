//
//  CommunityFeature.swift
//  pawrest
//
//  Created by 소은 on 5/20/26.
//

import ComposableArchitecture

// MARK: - State

@ObservableState  
struct CommunityState: Equatable {
    var navigationBar = NavigationBarState(
        title: "커뮤니티",
        leftButton: .back,
        rightButton: .editMenu
    )
    var text: String = ""
}

// MARK: - Action

@CasePathable
enum CommunityAction: Equatable {
    case navigationBar(NavigationBarAction)
    case textChanged(String)
}

// MARK: - Reducer

struct CommunityReducer: Reducer {
    var body: some Reducer<CommunityState, CommunityAction> {
        Scope(state: \.navigationBar, action: \.navigationBar) {
            NavigationBarReducer()
        }
        
        Reduce { state, action in
            switch action {
            case .navigationBar(.leftButtonTapped):
                print("뒤로가기")
                return .none
                
            case .navigationBar(.editTapped):
                print("수정하기")
                return .none
                
            case .navigationBar(.deleteTapped):
                print("삭제하기")
                return .none
                
            case .navigationBar:
                return .none
                
            case .textChanged(let newText):
                state.text = newText
                return .none
            }
        }
    }
}
