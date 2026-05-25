//
//  AddImageGridFeature.swift
//  pawrest
//
//  Created by 소은 on 5/21/26.
//

import ComposableArchitecture
import PhotosUI
import SwiftUI

public struct AddImageGridFeature: Reducer {
    
    // MARK: - State
    
    @ObservableState
    public struct State: Equatable {
        public var selectedImages: [UIImage] = []
        public var pickerItems: [PhotosPickerItem] = []
        
        public init() {}
    }
    
    // MARK: - Action
    
    public enum Action: Equatable {
        case imagesChanged([UIImage])
        case pickerItemsChanged([PhotosPickerItem])
        
        public static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case let (.imagesChanged(lhsImages), .imagesChanged(rhsImages)):
                return lhsImages.count == rhsImages.count
            case let (.pickerItemsChanged(lhsItems), .pickerItemsChanged(rhsItems)):
                return lhsItems == rhsItems
            default:
                return false
            }
        }
    }
    
    // MARK: - Reducer
    
    public init() {}
    
    public var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case let .imagesChanged(images):
                state.selectedImages = images
                return .none
                
            case let .pickerItemsChanged(items):
                state.pickerItems = items
                return .none
            }
        }
    }
}
