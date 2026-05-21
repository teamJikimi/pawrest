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
    
    @Presents var addMemory: AddMemoryState?
}

// MARK: - Action

@CasePathable
enum MemoryAction: Equatable {
    case navigationBar(NavigationBarAction)
    case addMemory(PresentationAction<AddMemoryAction>)
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
                state.addMemory = AddMemoryState()
                return .none
                
            case .navigationBar:
                return .none
                
            case .addMemory(.presented(.navigationBar(.leftButtonTapped))):
                state.addMemory = nil
                return .none
                
            case .addMemory:
                return .none
            }
        }
        .ifLet(\.$addMemory, action: \.addMemory) {
            AddMemoryReducer()
        }
    }
}
