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
        var dateText: String = Self.formattedDate()

        static func formattedDate() -> String {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "MM월 dd일 (E) HH:mm"
            return formatter.string(from: Date())
        }
    }

    enum Action: Equatable {
        case emotionTapped(EmotionType)
        case memoTextChanged(String)
        case submitTapped
        case onAppear
        case tickTimer
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .onAppear:
            state.dateText = State.formattedDate()
            return .run { send in
                while true {
                    let now = Date()
                    let calendar = Calendar.current
                    let seconds = calendar.component(.second, from: now)
                    let nano = calendar.component(.nanosecond, from: now)
                    let delay = Double(60 - seconds) - Double(nano) / 1_000_000_000
                    try await Task.sleep(for: .seconds(max(delay, 1)))
                    await send(.tickTimer)
                }
            }
            .cancellable(id: "emotionTimer", cancelInFlight: true)

        case .tickTimer:
            state.dateText = State.formattedDate()
            return .none

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
