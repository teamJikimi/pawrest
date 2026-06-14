//
//  HomeView.swift
//  pawrest
//
//  Created by 소은 on 5/17/26.
//

import SwiftUI
import ComposableArchitecture

struct HomeView: View {
    let store: StoreOf<HomeFeature>

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    EmotionCheckInCard(
                        store: store.scope(
                            state: \.emotionCheckIn,
                            action: \.emotionCheckIn
                        )
                    )
                    RecommendedContentCard(
                        store: store.scope(
                            state: \.recommendedContent,
                            action: \.recommendedContent
                        )
                    )
                    RecentRecordCard(
                        store: store.scope(
                            state: \.recentRecord,
                            action: \.recentRecord
                        )
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .onAppear {
                store.send(.onAppear)
            }
            .customNavigationBar(
                store: store.scope(
                    state: \.navigationBar,
                    action: \.navigationBar
                )
            )
            .navigationDestination(isPresented: Binding(
                get: { store.isAlarmPresented },
                set: { _ in }
            )) {
                AlarmView(
                    store: Store(initialState: AlarmFeature.State()) {
                        AlarmFeature()
                    }
                )
            }
            .navigationDestination(isPresented: Binding(
                get: { store.isReportPresented },
                set: { _ in }
            )) {
                ReportView(
                    store: Store(initialState: ReportFeature.State()) {
                        ReportFeature()
                    }
                )
            }
        }
    }
}

#Preview {
    HomeView(
        store: Store(initialState: HomeFeature.State(
            emotionCheckIn: .mock
        )) {
            HomeFeature()
        }
    )
}
