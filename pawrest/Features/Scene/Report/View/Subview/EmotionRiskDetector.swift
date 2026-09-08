//
//  EmotionRiskDetector.swift
//  pawrest
//
//  Created by 소은 on 9/3/26.
//

import Foundation

struct EmotionRiskDetector {
    let records: [EmotionRecordModel]

    var shouldShowCounselingBanner: Bool {
        isConsecutive7DaysNegative || isNegative5of7Days
    }

    var isConsecutive7DaysNegative: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        for offset in 0..<7 {
            let day = calendar.date(byAdding: .day, value: -offset, to: today)!
            let record = records.first { calendar.isDate($0.recordedAt, inSameDayAs: day) }
            guard let level = record?.emotionTypeEnum?.toEmotionLevel, level.rawValue <= 2 else {
                return false
            }
        }
        return true
    }

    var isNegative5of7Days: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var count = 0
        for offset in 0..<7 {
            let day = calendar.date(byAdding: .day, value: -offset, to: today)!
            let record = records.first { calendar.isDate($0.recordedAt, inSameDayAs: day) }
            if let level = record?.emotionTypeEnum?.toEmotionLevel, level.rawValue <= 2 {
                count += 1
            }
        }
        return count >= 5
    }
}
