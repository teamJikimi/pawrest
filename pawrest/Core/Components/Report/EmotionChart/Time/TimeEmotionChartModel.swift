//
//  TimeEmotionChartModel.swift
//  pawrest
//
//  Created by 소은 on 6/4/26.
//

import Foundation

struct TimeSlotEmotion: Identifiable, Equatable {
    let id: UUID
    let timeSlot: TimeSlot
    let level: EmotionLevel?

    init(id: UUID = UUID(), timeSlot: TimeSlot, level: EmotionLevel?) {
        self.id = id
        self.timeSlot = timeSlot
        self.level = level
    }

    enum TimeSlot: Int, CaseIterable {
        case morning = 0    // 아침
        case forenoon = 1   // 오전
        case afternoon = 2  // 오후
        case evening = 3    // 저녁
        case night = 4      // 밤

        var label: String {
            switch self {
            case .morning:   return "아침"
            case .forenoon:  return "오전"
            case .afternoon: return "오후"
            case .evening:   return "저녁"
            case .night:     return "밤"
            }
        }
    }
}

struct DailyTimeEmotionData: Equatable {
    let date: Date
    let slots: [TimeSlotEmotion]
    let insight: String?

    var hasData: Bool {
        slots.contains { $0.level != nil }
    }

    var dateLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 (E)"
        return formatter.string(from: date)
    }
}

