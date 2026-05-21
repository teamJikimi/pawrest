//
//  AddMemoryFeature.swift
//  pawrest
//
//  Created by 소은 on 5/21/26.
//

import ComposableArchitecture

// MARK: - State

@ObservableState
struct AddMemoryState: Equatable {
    var navigationBar = NavigationBarState(
        title: "추억 기록",
        leftButton: .back,
        rightButton: .none
    )
    
    var imageGrid = AddImageGridFeature.State()
    
    var title: String = ""
    var content: String = ""
}

// MARK: - Action

@CasePathable
enum AddMemoryAction: Equatable {
    case navigationBar(NavigationBarAction)
    case imageGrid(AddImageGridFeature.Action)
    
    case titleChanged(String)
    case contentChanged(String)
    case saveButtonTapped
}

// MARK: - Reducer

struct AddMemoryReducer: Reducer {
    var body: some Reducer<AddMemoryState, AddMemoryAction> {
        Scope(state: \.navigationBar, action: \.navigationBar) {
            NavigationBarReducer()
        }
        
        Scope(state: \.imageGrid, action: \.imageGrid) {
            AddImageGridFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .navigationBar(.leftButtonTapped):
                return .none
                
            case .navigationBar:
                return .none
                
            case .imageGrid:
                return .none
                
            case let .titleChanged(title):
                state.title = title
                return .none
                
            case let .contentChanged(content):
                state.content = content
                return .none
                
            case .saveButtonTapped:
                print("저장하기")
                return .none
            }
        }
    }
}
