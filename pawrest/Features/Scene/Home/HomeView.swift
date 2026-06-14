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
    @Binding var isTabBarHidden: Bool

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
                set: { _ in store.send(.alarmDismissed) }
            )) {
                AlarmView(
                    store: Store(initialState: AlarmFeature.State()) {
                        AlarmFeature()
                    }
                )
                .onAppear {
                    isTabBarHidden = true
                }
                .onDisappear() {
                    isTabBarHidden = false
                }
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
