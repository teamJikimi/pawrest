//
//  WeekdayEmotionChartModel.swift
//  pawrest
//
//  Created by 소은 on 6/4/26.
//

import Foundation

struct WeekdayEmotionData: Equatable {
    let entries: [WeekdayEntry]
    let insight: String?

    var hasData: Bool {
        entries.contains { $0.level != nil }
    }

    struct WeekdayEntry: Identifiable, Equatable {
        let id: UUID
        let weekday: Int 
        let level: EmotionLevel?

        init(id: UUID = UUID(), weekday: Int, level: EmotionLevel?) {
            self.id = id
            self.weekday = weekday
            self.level = level
        }

        var label: String {
            ["일","월","화","수","목","금","토"][weekday]
        }
    }
}
