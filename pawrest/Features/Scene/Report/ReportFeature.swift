//
//  ReportFeature.swift
//  pawrest
//
//  Created by 소은 on 6/4/26.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ReportFeature {

    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var reportData: ReportData?
        var dailyTimeData: DailyTimeEmotionData = .mock
        var selectedTab: ReportTab = .daily
        var isLoading: Bool = false
        var errorMessage: String? = nil

        var navigationBar: NavigationBarState = NavigationBarState(title: "리포트")
    }

    // MARK: - Action
    @CasePathable
    enum Action: Equatable {
        case onAppear
        case reportDataLoaded(ReportData)
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
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    do {
                        let data = try await useCase.fetchReportData()
                        await send(.reportDataLoaded(data))
                    } catch {
                        await send(.loadFailed(error.localizedDescription))
                    }
                }

            case .reportDataLoaded(let data):
                state.reportData = data
                state.dailyTimeData = data.dailyTimeData
                state.isLoading = false
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
                return .run { send in
                    do {
                        let data = try await useCase.fetchDailyTimeEmotion(for: newDate)
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
                return .run { send in
                    do {
                        let data = try await useCase.fetchDailyTimeEmotion(for: newDate)
                        await send(.dailyTimeDataLoaded(data))
                    } catch {
                        await send(.loadFailed(error.localizedDescription))
                    }
                }

            case .loadFailed(let message):
                state.errorMessage = message
                state.isLoading = false
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
