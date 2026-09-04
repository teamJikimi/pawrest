//
//  ReportFeature.swift
//  pawrest
//
//  Created by 소은 on 6/4/26.
//

import Foundation
import ComposableArchitecture
import SwiftData

@Reducer
struct ReportFeature {

    // MARK: - State

    @ObservableState
    struct State: Equatable {
        var reportData: ReportData?
        var dailyTimeData: DailyTimeEmotionData = .empty
        var selectedTab: ReportTab = .daily
        var isLoading: Bool = false
        var isAILoading: Bool = false
        var isAILoadFailed: Bool = false
        var errorMessage: String? = nil
        var emotionSnapshots: [EmotionSnapshot] = []
        var navigationBar: NavigationBarState = NavigationBarState(title: "리포트")
    }

    // MARK: - Action

    @CasePathable
    enum Action {
        case onAppear(snapshots: [EmotionSnapshot], context: ModelContext)
        case aiDataLoaded(AIReportResult, weekdayInsight: String?, todayTimeData: DailyTimeEmotionData)
        case dailyTimeDataLoaded(DailyTimeEmotionData)
        case tabChanged(ReportTab)
        case previousDayTapped
        case nextDayTapped
        case loadFailed(String)
        case navigationBar(NavigationBarAction)
    }

    // MARK: - Dependencies

    let useCase: ReportUseCaseProtocol

    init(useCase: ReportUseCaseProtocol = ReportUseCase()) {
        self.useCase = useCase
    }

    // MARK: - Reducer

    var body: some Reducer<State, Action> {
        Scope(state: \.navigationBar, action: \.navigationBar) {
            NavigationBarReducer()
        }

        Reduce { state, action in
            switch action {

            case .onAppear(let snapshots, let context):
                state.emotionSnapshots = snapshots
                state.isAILoadFailed = false
                let localData = useCase.buildLocalData(snapshots: snapshots)
                state.reportData = localData
                state.dailyTimeData = localData.dailyTimeData
                state.isAILoading = true
                let container = context.container

                return .run { [snapshots, useCase] send in
                    do {
                        let (aiResult, weekdayInsight, todayTimeData) = try await useCase.fetchAIData(
                            emotionSnapshots: snapshots,
                            container: container
                        )
                        await send(.aiDataLoaded(aiResult, weekdayInsight: weekdayInsight, todayTimeData: todayTimeData))
                    } catch {
                        await send(.loadFailed(error.localizedDescription))
                    }
                }

            case .aiDataLoaded(let result, let weekdayInsight, let todayTimeData):
                state.isAILoading = false
                state.isAILoadFailed = false
                guard let data = state.reportData else { return .none }
                state.reportData = ReportData(
                    weekRange: data.weekRange,
                    summaryTitle: result.bannerTitle,
                    summaryBody: result.bannerSummary,
                    aiSummary: result.weeklySummary,
                    stats: data.stats,
                    statusCards: data.statusCards,
                    weeklyChart: WeeklyEmotionChartData(
                        entries: data.weeklyChart.entries,
                        insight: result.dailyInsight
                    ),
                    dailyTimeData: todayTimeData,
                    weekdayData: WeekdayEmotionData(
                        entries: data.weekdayData.entries,
                        insight: weekdayInsight
                    )
                )
                state.dailyTimeData = todayTimeData
                return .none

            case .dailyTimeDataLoaded(let data):
                state.dailyTimeData = data
                return .none

            case .tabChanged(let tab):
                state.selectedTab = tab
                return .none

            case .previousDayTapped:
                let snapshots = state.emotionSnapshots
                guard let newDate = Calendar.current.date(
                    byAdding: .day, value: -1, to: state.dailyTimeData.date
                ) else { return .none }
                return .run { send in
                    do {
                        let data = try await useCase.fetchDailyTimeEmotion(for: newDate, emotionSnapshots: snapshots)
                        await send(.dailyTimeDataLoaded(data))
                    } catch {
                        await send(.loadFailed(error.localizedDescription))
                    }
                }

            case .nextDayTapped:
                let snapshots = state.emotionSnapshots
                let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.startOfDay(for: Date()))!
                guard state.dailyTimeData.date < yesterday,
                      let newDate = Calendar.current.date(
                        byAdding: .day, value: 1, to: state.dailyTimeData.date
                      ) else { return .none }
                return .run { send in
                    do {
                        let data = try await useCase.fetchDailyTimeEmotion(for: newDate, emotionSnapshots: snapshots)
                        await send(.dailyTimeDataLoaded(data))
                    } catch {
                        await send(.loadFailed(error.localizedDescription))
                    }
                }
                
            case .loadFailed(let message):
                state.errorMessage = message
                state.isLoading = false
                state.isAILoading = false
                state.isAILoadFailed = true
                return .none

            case .navigationBar:
                return .none
            }
        }
    }
}

// MARK: - ReportTab

enum ReportTab: String, CaseIterable, SegmentItem {
    case daily   = "일별"
    case time    = "시간대별"
    case weekday = "요일별"

    var title: String { rawValue }
}
