
//
//  EmotionChartMock.swift
//  pawrest
//
//  Created by 소은 on 6/1/26.
//

import Foundation

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
                .frustrated,
                .normal,
                .depressed,
                .normal,
                .stable,
                .relaxed,
                .stable
            ]),
            insight: "이번 주 초반엔 감정 기복이 있었지만, 후반부로 갈수록 점차 안정되는 모습이에요. 특히 금요일에 편안함이 크게 올라왔네요."
        )
    }

    static var partial: WeeklyEmotionChartData {
        WeeklyEmotionChartData(
            entries: makeEntries(levels: [
                nil, nil, .depressed, .normal, nil, .stable, .relaxed
            ]),
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
            entries: makeEntries(levels: [
                .normal,    // 오늘
                nil,        // +1일
                .stable,    // +2일
                nil,        // +3일
                nil,        // +4일
                .relaxed,   // +5일
                .frustrated // +6일
            ]),
            insight: "기록이 띄엄띄엄 있어요."
        )
    }
    
    static var singleDots: WeeklyEmotionChartData {
        WeeklyEmotionChartData(
            entries: makeEntries(levels: [
                .normal,
                nil,
                .stable,
                nil,
                .relaxed,
                nil,
                .frustrated
            ]),
            insight: "띄엄띄엄 기록된 한 주예요."
        )
    }
}
