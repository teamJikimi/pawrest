//
//  HomeView.swift
//  pawrest
//
//  Created by 소은 on 5/17/26.
//

import SwiftUI
import ComposableArchitecture
import Combine

struct HomeView: View {
    let store: StoreOf<HomeFeature>
    @State private var reportStore = Store(initialState: ReportFeature.State()) {
        ReportFeature()
    }
    @State private var selfAssessmentStore: StoreOf<SelfAssessmentReducer>? = nil

    var body: some View {
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
                SelfAssessmentCard { type in
                    store.send(.selfAssessmentTapped(type))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 80)
        }
        .scrollDismissesKeyboard(.immediately)
        .onAppear {
            store.send(.onAppear)
        }
        .onChange(of: store.selfAssessmentType) { _, type in
            if let type {
                selfAssessmentStore = Store(
                    initialState: SelfAssessmentState(type: type)
                ) {
                    SelfAssessmentReducer()
                }
            }
        }
        .customNavigationBar(
            store: store.scope(
                state: \.navigationBar,
                action: \.navigationBar
            )
        )
        .fullScreenCover(
            isPresented: Binding(
                get: { store.selectedSelfAssessmentType != nil },
                set: { isPresented in
                    if !isPresented {
                        store.send(.selfAssessmentOverlayDismissed)
                    }
                }
            ),
            content: {
                if let selectedType = store.selectedSelfAssessmentType {
                    SelfAssessmentSelectedOverlay(
                        type: selectedType,
                        onStart: {
                            store.send(.selfAssessmentStartTapped)
                        },
                        onDismiss: {
                            store.send(.selfAssessmentOverlayDismissed)
                        }
                    )
                    .presentationBackground(.clear)
                }
            }
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
        }
        .navigationDestination(isPresented: Binding(
            get: { store.isReportPresented },
            set: { if !$0 { store.send(.reportDismissed) } }
        )) {
            ReportView(store: reportStore)
        }
        .navigationDestination(isPresented: Binding(
            get: { store.isSelfAssessmentPresented },
            set: { if !$0 { store.send(.selfAssessmentDismissed) } }
        )) {
            if let selfAssessmentStore {
                SelfAssessmentView(store: selfAssessmentStore)
                    .onReceive(selfAssessmentStore.publisher.map(\.shouldDismiss).removeDuplicates()) { shouldDismiss in
                        if shouldDismiss {
                            store.send(.selfAssessmentDismissed)
                        }
                    }
            }
        }
        .navigationDestination(isPresented: Binding(
            get: { store.selectedRecommendedContentID != nil },
            set: { if !$0 { store.send(.recommendedContentDetailDismissed) } }
        )) {
            if let id = store.selectedRecommendedContentID,
               let item = store.recommendedContent.items.first(where: { $0.id == id }) {
                RecommendContentDetailView(detail: item.detail)
            }
        }
    }
}
