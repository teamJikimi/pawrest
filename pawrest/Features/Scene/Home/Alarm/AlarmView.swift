//
//  AlarmView.swift
//  pawrest
//
//  Created by 소은 on 6/12/26.
//

import SwiftUI
import SwiftData
import ComposableArchitecture
import FirebaseAuth

struct AlarmView: View {
    let store: StoreOf<AlarmFeature>
    
    @Query(sort: \NotificationRecord.receivedAt, order: .reverse)
    private var notifications: [NotificationRecord]
    
    @State private var selectedPost: Post? = nil
    @State private var isDetailPresented: Bool = false
    
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
                                .onTapGesture {
                                    handleTap(record: record)
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
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
        .navigationDestination(isPresented: $isDetailPresented) {
            if let post = selectedPost,
               let userID = Auth.auth().currentUser?.uid {
                CommunityDetailView(
                    store: Store(
                        initialState: CommunityDetailState(
                            post: post,
                            currentUserID: userID,
                            authorName: ""
                        ),
                        reducer: { CommunityDetailReducer() }
                    )
                )
            }
        }
        .hideTabBar()
    }
}

// MARK: - AlarmRow

private struct AlarmRow: View {
    let record: NotificationRecord
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray10)
                Image(record.notificationType.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            }
            .frame(width: 32, height: 32)
            
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
        VStack(spacing: 10) {
            Image("icon_no_alarm")
            Text("아직 알림이 없어요")
                .typography(.body2R1)
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

//MARK: - handle
private extension AlarmView {
    func handleTap(record: NotificationRecord) {
        guard let postID = record.postID else { return }
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        Task {
            let service = await MainActor.run { CommunityFirestoreService() }
            let postDTOs = try? await service.fetchPosts()
            guard let dto = postDTOs?.first(where: { $0.id == postID }) else { return }
            
            let post = dto.toDomain()
            await MainActor.run {
                selectedPost = post
                isDetailPresented = true
            }
        }
    }
}
