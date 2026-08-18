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
        var dailyTimeData: DailyTimeEmotionData = .mock
        var selectedTab: ReportTab = .daily
        var isLoading: Bool = false
        var isAILoading: Bool = false
        var errorMessage: String? = nil
        var emotionSnapshots: [EmotionSnapshot] = []
        var navigationBar: NavigationBarState = NavigationBarState(title: "리포트")
    }

    // MARK: - Action
    @CasePathable
    enum Action: Equatable {
        case onAppear(snapshots: [EmotionSnapshot], context: ModelContext)
        case localDataLoaded(ReportData)
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
                state.isLoading = true
                state.isAILoading = true
                return .run { send in
                    do {
                        // 1단계: 로컬 데이터 즉시 표시
                        let localData = useCase.buildLocalData()
                        await send(.localDataLoaded(localData))

                        // 2단계: AI 호출
                        let (aiResult, weekdayInsight, todayTimeData) = try await useCase.fetchAIData(
                            emotionSnapshots: snapshots,
                            context: context
                        )
                        await send(.aiDataLoaded(aiResult, weekdayInsight: weekdayInsight, todayTimeData: todayTimeData))
                    } catch {
                        print("[ReportFeature] loadFailed: \(error.localizedDescription)")
                        await send(.loadFailed(error.localizedDescription))
                    }
                }

            case .localDataLoaded(let data):
                state.reportData = data
                state.isLoading = false
                return .none

            case .aiDataLoaded(let aiResult, let weekdayInsight, let todayTimeData):
                state.isAILoading = false
                state.dailyTimeData = todayTimeData
                if var data = state.reportData {
                    data = ReportData(
                        weekRange: data.weekRange,
                        summaryTitle: aiResult.bannerTitle,
                        summaryBody: aiResult.bannerSummary,
                        aiSummary: aiResult.weeklySummary,
                        stats: data.stats,
                        statusCards: data.statusCards,
                        weeklyChart: WeeklyEmotionChartData(entries: data.weeklyChart.entries, insight: aiResult.dailyInsight),
                        dailyTimeData: todayTimeData,
                        weekdayData: WeekdayEmotionData(entries: data.weekdayData.entries, insight: weekdayInsight)
                    )
                    state.reportData = data
                }
                return .none

            case .dailyTimeDataLoaded(let data):
                state.dailyTimeData = data
                return .none

            case .tabChanged(let tab):
                state.selectedTab = tab
                return .none

            case .previousDayTapped:
                guard let newDate = Calendar.current.date(
                    byAdding: .day, value: -1, to: state.dailyTimeData.date
                ) else { return .none }
                let snapshots = state.emotionSnapshots
                return .run { send in
                    do {
                        let data = try await useCase.fetchDailyTimeEmotion(for: newDate, emotionSnapshots: snapshots)
                        await send(.dailyTimeDataLoaded(data))
                    } catch {
                        await send(.loadFailed(error.localizedDescription))
                    }
                }

            case .nextDayTapped:
                guard !Calendar.current.isDateInToday(state.dailyTimeData.date),
                      let newDate = Calendar.current.date(
                        byAdding: .day, value: 1, to: state.dailyTimeData.date
                      ) else { return .none }
                let snapshots = state.emotionSnapshots
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
                return .none

            case .navigationBar:
                return .none
            }
        }
    }
}

// MARK: - ReportTab
enum ReportTab: String, CaseIterable, SegmentItem {
    case daily = "일별"
    case time = "시간대별"
    case weekday = "요일별"

    var title: String { rawValue }
}
