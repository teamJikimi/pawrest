//
//  MemorialFeature.swift
//  pawrest
//
//  Created by 소은 on 5/20/26.
//

import ComposableArchitecture

struct PendingLetter: Equatable {
    let petName: String
    let content: String
}

// MARK: - State

@ObservableState
struct MemorialState: Equatable {
    var petName: String = ""
    var isLetterPresented: Bool = false
    var pendingSave: PendingLetter? = nil
    var letter: LetterState?
}

// MARK: - Action

@CasePathable
enum MemorialAction: Equatable {
    case sendLetterButtonTapped
    case letterDismissed
    case letterSaved
    case letter(LetterAction)
    case setPetName(String)
}

// MARK: - Reducer

struct MemorialReducer: Reducer {
    var body: some Reducer<MemorialState, MemorialAction> {
        Reduce { state, action in
            switch action {
            case .setPetName(let name):
                state.petName = name
                return .none

            case .sendLetterButtonTapped:
                state.letter = LetterState(petName: state.petName)
                state.isLetterPresented = true
                return .none

            case .letter(.delegate(.didSend)):
                state.pendingSave = PendingLetter(
                    petName: state.petName,
                    content: state.letter?.content ?? ""
                )
                state.isLetterPresented = false
                state.letter = nil
                return .none

            case .letter(.delegate(.didClose)), .letterDismissed:
                state.isLetterPresented = false
                state.letter = nil
                return .none

            case .letterSaved:
                state.pendingSave = nil
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
