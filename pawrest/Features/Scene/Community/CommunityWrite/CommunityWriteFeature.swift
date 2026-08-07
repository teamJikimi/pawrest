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
    
    var editingPostID: String? = nil
    var existingImageURLs: [String] = []
    
    var isEditMode: Bool { editingPostID != nil }
    
    var isSaveButtonEnabled: Bool {
        if isEditMode { return true }
        return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init() {}
    
    init(editingPost: Post) {
        self.editingPostID = editingPost.id
        self.title = editingPost.title
        self.content = editingPost.content
        self.existingImageURLs = editingPost.imageURLs
        self.navigationBar = NavigationBarState (
            title: "글 수정",
            leftButton: .back,
            rightButton: .none
        )
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
    
    case loadExistingImages
    case existingImagesLoaded([UIImage])
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
                state.shouldDismiss = true
                return .none
                
            case .loadExistingImages:
                let urls = state.existingImageURLs
                guard !urls.isEmpty else { return .none }
                return .run { send in
                    var images: [UIImage] = []
                    for urlString in urls {
                        guard let url = URL(string: urlString),
                              let data = try? Data(contentsOf: url),
                              let image = UIImage(data: data)
                        else { continue }
                        images.append(image)
                    }
                    await send(.existingImagesLoaded(images))
                }
                
            case .existingImagesLoaded(let images):
                state.imageGrid.selectedImages = images
                return .none
            }
        }
    }
}
