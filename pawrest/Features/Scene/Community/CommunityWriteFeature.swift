//
//  CommunityWriteFeature.swift
//  pawrest
//
//  Created by Moon AYoung on 6/7/26.
//

import Foundation
import UIKit
import ComposableArchitecture

// MARK: - State

@ObservableState
struct CommunityWriteState: Equatable {
    var navigationBar = NavigationBarState(
        title: "글 쓰기",
        leftButton: .back,
        rightButton: .none
    )
    
    var imageGrid = AddImageGridFeature.State()
    
    var title: String = ""
    var content: String = ""
    
    var shouldDismiss: Bool = false
    
    var isSaveButtonEnabled: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Action

@CasePathable
enum CommunityWriteAction: Equatable {
    case navigationBar(NavigationBarAction)
    case imageGrid(AddImageGridFeature.Action)
    
    case titleChanged(String)
    case contentChanged(String)
    case saveButtonTapped
}

// MARK: - Reducer

struct CommunityWriteReducer: Reducer {
    var body: some Reducer<CommunityWriteState, CommunityWriteAction> {
        Scope(state: \.navigationBar, action: \.navigationBar) {
            NavigationBarReducer()
        }
        
        Scope(state: \.imageGrid, action: \.imageGrid) {
            AddImageGridFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .navigationBar(.leftButtonTapped):
                state.shouldDismiss = true
                return .none
                
            case .navigationBar:
                return .none
                
            case .imageGrid:
                return .none
                
            case .titleChanged(let title):
                state.title = title
                return .none
                
            case .contentChanged(let content):
                state.content = content
                return .none
                
            case .saveButtonTapped:
                print("✅ 커뮤니티 글 저장: \(state.title)")
                state.shouldDismiss = true
                return .none
            }
        }
    }
}
