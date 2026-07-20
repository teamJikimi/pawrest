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
    var petName: String = "@@"
    var isLetterPresented: Bool = false
    var letter: LetterState?
}

// MARK: - Action

@CasePathable
enum MemorialAction: Equatable {
    case sendLetterButtonTapped
    case letter(LetterAction)
}

// MARK: - Reducer

struct MemorialReducer: Reducer {
    var body: some Reducer<MemorialState, MemorialAction> {
        Reduce { state, action in
            switch action {
            case .sendLetterButtonTapped:
                state.letter = LetterState(petName: state.petName)
                state.isLetterPresented = true
                return .none

            case .letter(.delegate(.didSend)), .letter(.delegate(.didClose)):
                state.isLetterPresented = false
                state.letter = nil
                return .none

            case .letter:
                return .none
            }
        }
        .ifLet(\.letter, action: \.letter) {
            LetterReducer()
        }
    }
}
