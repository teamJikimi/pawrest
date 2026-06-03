
//
//  EmotionChartMock.swift
//  pawrest
//
//  Created by 소은 on 6/1/26.
//

import Foundation

// MARK: - WeeklyEmotionChartData Mock
extension WeeklyEmotionChartData {

    static func makeEntries(levels: [EmotionLevel?]) -> [DailyEmotionEntry] {
        precondition(levels.count == 7)
        let today = Calendar.current.startOfDay(for: Date())
        return (0..<7).map { i in
            let date = Calendar.current.date(byAdding: .day, value: i - 6, to: today)!
            return DailyEmotionEntry(date: date, level: levels[i])
        }
    }

    static var mock: WeeklyEmotionChartData {
        WeeklyEmotionChartData(
            entries: makeEntries(levels: [
                .frustrated, .normal, .depressed, .normal, .stable, .relaxed, .stable
            ]),
            insight: "이번 주 초반엔 감정 기복이 있었지만, 후반부로 갈수록 점차 안정되는 모습이에요. 특히 금요일에 편안함이 크게 올라왔네요."
        )
    }

    static var partial: WeeklyEmotionChartData {
        WeeklyEmotionChartData(
            entries: makeEntries(levels: [nil, nil, .depressed, .normal, nil, .stable, .relaxed]),
            insight: "기록이 있는 날들을 보면 점점 안정을 찾아가고 있어요. 꾸준히 기록해보는 건 어떨까요?"
        )
    }

    static var empty: WeeklyEmotionChartData {
        WeeklyEmotionChartData(
            entries: makeEntries(levels: Array(repeating: nil, count: 7)),
            insight: nil
        )
    }

    static var gap: WeeklyEmotionChartData {
        WeeklyEmotionChartData(
            entries: makeEntries(levels: [.normal, nil, .stable, nil, nil, .relaxed, .frustrated]),
            insight: "기록이 띄엄띄엄 있어요."
        )
    }

    static var singleDots: WeeklyEmotionChartData {
        WeeklyEmotionChartData(
            entries: makeEntries(levels: [.normal, nil, .stable, nil, .relaxed, nil, .frustrated]),
            insight: "띄엄띄엄 기록된 한 주예요."
        )
    }
}

// MARK: - DailyTimeEmotionData Mock
extension DailyTimeEmotionData {
    static var mock: DailyTimeEmotionData {
        DailyTimeEmotionData(
            date: Date(),
            slots: TimeSlotEmotion.TimeSlot.allCases.map { slot in
                let levels: [EmotionLevel?] = [.frustrated, .relaxed, .stable, .normal, .depressed]
                return TimeSlotEmotion(timeSlot: slot, level: levels[slot.rawValue])
            },
            insight: "오전에 감정이 가장 높았고 밤으로 갈수록 점차 낮아지는 패턴이에요."
        )
    }

    static var empty: DailyTimeEmotionData {
        DailyTimeEmotionData(
            date: Date(),
            slots: TimeSlotEmotion.TimeSlot.allCases.map {
                TimeSlotEmotion(timeSlot: $0, level: nil)
            },
            insight: nil
        )
    }
}

// MARK: - WeekdayEmotionData Mock
extension WeekdayEmotionData {
    static var mock: WeekdayEmotionData {
        let levels: [EmotionLevel?] = [.normal, .stable, .relaxed, .frustrated, .depressed, .normal, .stable]
        return WeekdayEmotionData(
            entries: (0..<7).map { WeekdayEntry(weekday: $0, level: levels[$0]) },
            insight: "화요일에 감정이 가장 높고 목요일에 가장 낮은 패턴이 반복되고 있어요."
        )
    }

    static var empty: WeekdayEmotionData {
        WeekdayEmotionData(
            entries: (0..<7).map { WeekdayEntry(weekday: $0, level: nil) },
            insight: nil
        )
    }
}
