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

#Preview {
    AlarmView(
        store: Store(
            initialState: AlarmFeature.State(),
            reducer: { AlarmFeature() }
        )
    )
    .modelContainer(for: NotificationRecord.self, inMemory: true) { result in
        if let context = try? result.get().mainContext {
            let samples: [(NotificationType, String)] = [
                (.comment, "새로운 댓글이 달렸습니다: 힘내세요 정말로 응원해요"),
                (.like, "000님이 좋아요를 눌렀습니다."),
                (.memorialLetter, "오늘의 편지가 무지개 다리 너머로 전달됐어요."),
                (.anniversary, "○○이의 기일이에요. 편지를 보내볼까요?"),
                (.assessmentReminder, "마지막 자가진단이 3달 전이에요. 지금 상태를 한번 확인해볼까요?"),
                (.emotionReminder, "오늘 하루는 어떠셨나요? 감정을 기록해보세요.")
            ]
            for (type, body) in samples {
                let record = NotificationRecord(type: type, title: type.displayTitle, body: body)
                context.insert(record)
            }
        }
    }
}
