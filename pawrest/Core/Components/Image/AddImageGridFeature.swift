//
//  AddImageGridFeature.swift
//  pawrest
//
//  Created by 소은 on 5/21/26.
//

import ComposableArchitecture
import SwiftUI

public struct AddImageGridFeature: Reducer {

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var selectedImages: [UIImage] = []

        public init() {}
    }

    // MARK: - Action

    public enum Action: Equatable {
        case imagesChanged([UIImage])

        public static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case let (.imagesChanged(l), .imagesChanged(r)):
                return l.count == r.count
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
            }
        }
    }
}
