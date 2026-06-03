//
//  EmotionChartModel.swift
//  pawrest
//
//  Created by 소은 on 6/1/26.
//

import Foundation

enum EmotionLevel: Int, CaseIterable, Codable {
    case depressed = 0
    case frustrated = 1
    case normal = 2
    case stable = 3
    case relaxed = 4

    var label: String {
        switch self {
        case .depressed:  return "우울"
        case .frustrated: return "답답"
        case .normal:     return "보통"
        case .stable:     return "안정"
        case .relaxed:    return "편안"
        }
    }
}

struct DailyEmotion: Identifiable, Equatable {
    let id: UUID
    let date: Date
    let level: EmotionLevel

    init(id: UUID = UUID(), date: Date, level: EmotionLevel) {
        self.id = id
        self.date = date
        self.level = level
    }
}

struct WeeklyEmotionChartData: Equatable {
    let entries: [DailyEmotionEntry]
    let insight: String?

    var hasData: Bool {
        entries.contains { $0.level != nil }
    }

    struct DailyEmotionEntry: Identifiable, Equatable {
        let id: UUID
        let date: Date
        let level: EmotionLevel?

        init(id: UUID = UUID(), date: Date, level: EmotionLevel?) {
            self.id = id
            self.date = date
            self.level = level
        }

        var weekdayLabel: String {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "E"
            return String(formatter.string(from: date).prefix(1))
        }
    }
}
