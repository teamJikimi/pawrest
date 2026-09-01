//
//  AlarmView.swift
//  pawrest
//
//  Created by 소은 on 6/12/26.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

struct AlarmView: View {
    let store: StoreOf<AlarmFeature>

    @Query(sort: \NotificationRecord.receivedAt, order: .reverse)
    private var notifications: [NotificationRecord]

    var body: some View {
        ZStack {
            Color.gray10
                .ignoresSafeArea()

            if notifications.isEmpty {
                VStack {
                    Spacer().frame(height: 248)
                    emptyView
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(notifications) { record in
                            AlarmRow(record: record)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .customNavigationBar(
            store: Store(
                initialState: NavigationBarState(
                    title: "알림",
                    leftButton: .back,
                    rightButton: .none,
                    backgroundColor: .gray10
                )
            ) {
                NavigationBarReducer()
            }
        )
        .hideTabBar()
    }
}

// MARK: - AlarmRow

private struct AlarmRow: View {
    let record: NotificationRecord

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Rectangle()
                .fill(Color.gray10)
                .frame(width: 44, height: 44)
                .cornerRadius(10, corners: .allCorners)
                .overlay(
                    Image(record.notificationType.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                )

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(record.notificationType.displayTitle)
                        .typography(.body1M)
                        .foregroundStyle(.gray80)
                    Spacer()
                    Text(record.receivedAt.alarmTimeLabel)
                        .typography(.date)
                        .foregroundStyle(.gray50)
                }
                Text(record.body)
                    .typography(.body3R)
                    .foregroundStyle(.gray60)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(.white)
        .cornerRadius(12, corners: .allCorners)
    }
}
// MARK: - Subviews

private extension AlarmView {
    var emptyView: some View {
        VStack(spacing: 8) {
            Image("icon_no_alarm")
            Text("아직 알림이 없어요")
                .typography(.body3R)
                .foregroundStyle(.gray60)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Date helper

private extension Date {
    var alarmTimeLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: self)
    }
}

