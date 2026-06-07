//
//  ReportUseCase.swift
//  pawrest
//
//  Created by 소은 on 6/4/26.
//

import Foundation

protocol ReportUseCaseProtocol {
    func fetchReportData() async throws -> ReportData
    func fetchDailyTimeEmotion(for date: Date) async throws -> DailyTimeEmotionData
}

struct ReportUseCase: ReportUseCaseProtocol {
    func fetchReportData() async throws -> ReportData {
        // TODO: RemoteService 연결
        return .mock
    }

    func fetchDailyTimeEmotion(for date: Date) async throws -> DailyTimeEmotionData {
        // TODO: RemoteService 연결
        return DailyTimeEmotionData(
            date: date,
            slots: DailyTimeEmotionData.mock.slots,
            insight: DailyTimeEmotionData.mock.insight
        )
    }
}
