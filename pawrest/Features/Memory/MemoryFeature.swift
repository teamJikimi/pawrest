//
//  MemoryFeature.swift
//  pawrest
//
//  Created by 소은 on 5/20/26.
//

import ComposableArchitecture

// MARK: - State

@ObservableState
struct MemoryState: Equatable {
    var navigationBar = NavigationBarState(
        title: "추억 앨범",
        leftButton: .none,
        rightButton: .add
    )
}

// MARK: - Action

@CasePathable
enum MemoryAction: Equatable {
    case navigationBar(NavigationBarAction)
}

// MARK: - Reducer

struct MemoryReducer: Reducer {
    var body: some Reducer<MemoryState, MemoryAction> {
        Scope(state: \.navigationBar, action: \.navigationBar) {
            NavigationBarReducer()
        }
        
        Reduce { state, action in
            switch action {
            case .navigationBar(.rightButtonTapped):
                print("추가")
                return .none
                
            case .navigationBar:
                return .none
            }
        }
    }
}
