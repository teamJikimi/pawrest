//
//  LetterFeature.swift
//  pawrest
//
//  Created by 소은 on 7/20/26.
//

import Foundation
import ComposableArchitecture

// MARK: - State

@ObservableState
struct LetterState: Equatable {
    var petName: String
    var content: String = ""
    var isSendEnabled: Bool { !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
}

// MARK: - Action

@CasePathable
enum LetterAction: Equatable {
    case contentChanged(String)
    case sendButtonTapped
    case closeTapped
    case delegate(Delegate)

    @CasePathable
    enum Delegate: Equatable {
        case didSend
        case didClose
    }
}

// MARK: - Reducer

struct LetterReducer: Reducer {
    var body: some Reducer<LetterState, LetterAction> {
        Reduce { state, action in
            switch action {
            case .contentChanged(let text):
                state.content = text
                return .none

            case .sendButtonTapped:
                guard state.isSendEnabled else { return .none }
                // TODO: SwiftData 저장 + NotificationService.scheduleLetterDelivery 호출
                return .send(.delegate(.didSend))

            case .closeTapped:
                return .send(.delegate(.didClose))

            case .delegate:
                return .none
            }
        }
    }
}
