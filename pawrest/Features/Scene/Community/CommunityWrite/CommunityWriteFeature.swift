//
//  CommunityWriteFeature.swift
//  pawrest
//
//  Created by Moon AYoung on 6/7/26.
//

import Foundation
import UIKit
import ComposableArchitecture

// MARK: - PostImageItem

struct PostImageItem: Equatable, Identifiable {
    enum Source: Equatable {
        case remote(String)
        case local(UIImage)
    }
    
    let id: UUID
    let source: Source
    
    init(source: Source) {
        self.id = UUID()
        self.source = source
    }
    
    var uploadPayload: PostImagePayload? {
        switch source {
        case .remote(let url):
            return .remote(url: url)
        case .local(let image):
            guard let data = image.resizedJPEGData() else { return nil }
            return .local(data: data)
        }
    }
}

// MARK: - State

@ObservableState
struct CommunityWriteState: Equatable {
    var navigationBar = NavigationBarState(
        title: "글 쓰기",
        leftButton: .back,
        rightButton: .none
    )
    
    var title: String = ""
    var content: String = ""
    var images: [PostImageItem] = []
    
    var isSaveButtonEnabled: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init() {}
    
    init(editingPost: Post) {
        self.title = editingPost.title
        self.content = editingPost.content
        self.images = editingPost.imageURLs.map { PostImageItem(source: .remote($0)) }
        self.navigationBar = NavigationBarState(
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
    
    case titleChanged(String)
    case contentChanged(String)
    case imagesAdded([UIImage])
    case imageDeleted(PostImageItem.ID)
    case saveButtonTapped
    
    case delegate(Delegate)
    
    @CasePathable
    enum Delegate: Equatable {
        case save(title: String, content: String, images: [PostImageItem])
    }
}

// MARK: - Reducer

struct CommunityWriteReducer: Reducer {
    static let maxImageCount = 10
    
    var body: some Reducer<CommunityWriteState, CommunityWriteAction> {
        Scope(state: \.navigationBar, action: \.navigationBar) {
            NavigationBarReducer()
        }
        
        Reduce { state, action in
            switch action {
            case .navigationBar:
                return .none
                
            case .titleChanged(let title):
                state.title = title
                return .none
                
            case .contentChanged(let content):
                state.content = content
                return .none
                
            case .imagesAdded(let images):
                let remaining = Self.maxImageCount - state.images.count
                guard remaining > 0 else { return .none }
                state.images += images
                    .prefix(remaining)
                    .map { PostImageItem(source: .local($0)) }
                return .none
                
            case .imageDeleted(let id):
                state.images.removeAll { $0.id == id }
                return .none
                
            case .saveButtonTapped:
                guard state.isSaveButtonEnabled else { return .none }
                return .send(.delegate(.save(
                    title: state.title,
                    content: state.content,
                    images: state.images
                )))
                
            case .delegate:
                return .none
            }
        }
    }
}
