//
//  MemorialFeature.swift
//  pawrest
//
//  Created by 소은 on 5/20/26.
//

import ComposableArchitecture

// MARK: - State

@ObservableState
struct MemorialState: Equatable {
}

// MARK: - Action

@CasePathable
enum MemorialAction: Equatable {
}

// MARK: - Reducer

struct MemorialReducer: Reducer {
    var body: some Reducer<MemorialState, MemorialAction> {
        Reduce { state, action in
            return .none
        }
    }
}
