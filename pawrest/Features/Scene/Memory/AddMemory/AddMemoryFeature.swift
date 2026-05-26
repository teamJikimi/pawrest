//
//  AddMemoryFeature.swift
//  pawrest
//
//  Created by 소은 on 5/21/26.
//

import Foundation
import UIKit
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
    
    var isSaveButtonEnabled: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !imageGrid.selectedImages.isEmpty
    }
}

// MARK: - Action

@CasePathable
enum AddMemoryAction: Equatable {
    case navigationBar(NavigationBarAction)
    case imageGrid(AddImageGridFeature.Action)
    
    case titleChanged(String)
    case contentChanged(String)
    case saveButtonTapped
    
    case delegate(Delegate)
    
    @CasePathable
    enum Delegate: Equatable {
        case save(title: String, content: String, images: [UIImage])
    
        static func == (lhs: Delegate, rhs: Delegate) -> Bool {
            switch (lhs, rhs) {
            case let (.save(lTitle, lContent, lImages), .save(rTitle, rContent, rImages)):
                return lTitle == rTitle &&
                       lContent == rContent &&
                       lImages.count == rImages.count
            }
        }
    }
}

// MARK: - Reducer

struct AddMemoryReducer: Reducer {
    @Dependency(\.dismiss) var dismiss
    
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
                return .run { _ in await dismiss() }
                
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
                return .run { _ in
                    await dismiss()
                }
                
            case .delegate:
                return .none
            }
        }
    }
}
