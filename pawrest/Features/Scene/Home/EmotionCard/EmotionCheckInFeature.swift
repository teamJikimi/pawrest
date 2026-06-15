//
//  EmotionCheckInFeature.swift
//  pawrest
//
//  Created by 소은 on 6/12/26.
//

import Foundation
import ComposableArchitecture

struct EmotionCheckInFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var selectedEmotion: EmotionType? = nil
        var memoText: String = ""
        var dateText: String = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "MM월 dd일 (E) HH:mm"
            return formatter.string(from: Date())
        }()
    }

    enum Action: Equatable {
        case emotionTapped(EmotionType)
        case memoTextChanged(String)
        case submitTapped
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .emotionTapped(let emotion):
            if state.selectedEmotion == emotion {
                state.selectedEmotion = nil
            } else {
                state.selectedEmotion = emotion
            }
            state.memoText = ""
            return .none

        case .memoTextChanged(let text):
            state.memoText = text
            return .none

        case .submitTapped:
            state.selectedEmotion = nil
            state.memoText = ""
            return .none
        }
    }
}
