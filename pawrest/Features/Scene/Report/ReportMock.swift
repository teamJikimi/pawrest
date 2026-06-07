//
//  ReportMock.swift
//  pawrest
//
//  Created by 소은 on 6/4/26.
//

import Foundation

extension ReportData {
    static var mock: ReportData {
        ReportData(
            weekRange: "3월 24일 - 3월 30일, 2026",
            summaryTitle: "변화 한 줄 ~~ 보이고 있어요",
            summaryBody: "어쩌구저쩌구 한줄요약 이건이런내용",
            aiSummary: "어쩌구저쩌구 슈니님은 이런 감정이 나타났고 이런 변화가 보였고 막 이렇고 저렇고 이건 이런 내용이고 어쩌구저쩌구 이건 AI 감정 요약이에용",
            stats: ReportStats(
                recordedDays: 5,
                mostFrequentEmotion: "감정",
                lettersSent: 550
            ),
            statusCards: [
                StatusCardData(
                    title: "CES-D 우울감 척도",
                    date: "2026.04.10",
                    score: 0,
                    maxScore: 100,
                    previousScore: 10,
                    previousDate: Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
                    scaleType: .cesd
                ),
                StatusCardData(
                    title: "PDS 외상 스트레스",
                    date: "2026.03.14",
                    score: 20,
                    maxScore: 51,
                    previousScore: 18,
                    previousDate: Calendar.current.date(byAdding: .month, value: -3, to: Date())!,
                    scaleType: .pds
                )
            ],
            weeklyChart: .mock,
            dailyTimeData: .mock,
            weekdayData: .mock
        )
    }
}
