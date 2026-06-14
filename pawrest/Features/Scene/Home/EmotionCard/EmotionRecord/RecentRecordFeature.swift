//
//  RecentRecordFeature.swift
//  pawrest
//
//  Created by 소은 on 6/12/26.
//

import ComposableArchitecture
import Foundation
import SwiftData

// MARK: - Feature

struct RecentRecordFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var selectedDate: Date = Date()
        var records: [EmotionRecordModel] = []
    }

    @CasePathable
    enum Action: Equatable {
        case previousDateTapped
        case nextDateTapped
        case deleteRecord(UUID)
        case recordsLoaded([EmotionRecordModel])
        case reportTapped
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .previousDateTapped:
            state.selectedDate = Calendar.current.date(
                byAdding: .day,
                value: -1,
                to: state.selectedDate
            ) ?? state.selectedDate
            return .none

        case .nextDateTapped:
            state.selectedDate = Calendar.current.date(
                byAdding: .day,
                value: 1,
                to: state.selectedDate
            ) ?? state.selectedDate
            return .none

        case .deleteRecord:
            return .none

        case .recordsLoaded(let records):
            state.records = records
            return .none
        
        case .reportTapped:
            return .none
        }
    }
}
