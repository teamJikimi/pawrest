//
//  AlarmFeature.swift
//  pawrest
//
//  Created by 소은 on 6/12/26.
//

import ComposableArchitecture
import FirebaseFirestore
import FirebaseAuth

struct AlarmNotification: Equatable, Identifiable {
    let id: String
    let type: NotificationType
    let title: String
    let body: String
    let receivedAt: Date
}

struct AlarmFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var notifications: [AlarmNotification] = []
        var isLoading: Bool = false
        var errorMessage: String? = nil
    }

    @CasePathable
    enum Action: Equatable {
        case onAppear
        case notificationsLoaded([AlarmNotification])
        case loadFailed(String)
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .onAppear:
            state.isLoading = true
            return .run { send in
                guard let userID = Auth.auth().currentUser?.uid else {
                    print("🔔 AlarmFeature - userID 없음")
                    await send(.notificationsLoaded([]))
                    return
                }
                print("🔔 AlarmFeature - userID: \(userID)")
                do {
                    let db = Firestore.firestore()
                    let snapshot = try await db
                        .collection("users")
                        .document(userID)
                        .collection("notifications")
                        .order(by: "receivedAt", descending: true)
                        .limit(to: 100)
                        .getDocuments()
                    print("🔔 AlarmFeature - 문서 수: \(snapshot.documents.count)")
                    let items = snapshot.documents.compactMap { doc -> AlarmNotification? in
                        let data = doc.data()
                        guard
                            let typeRaw = data["type"] as? String,
                            let title = data["title"] as? String,
                            let body = data["body"] as? String,
                            let timestamp = data["receivedAt"] as? Timestamp
                        else {
                            print("🔔 파싱 실패: \(doc.data())")
                            return nil
                        }
                        let type = NotificationType(rawValue: typeRaw) ?? .emotionReminder
                        return AlarmNotification(
                            id: doc.documentID,
                            type: type,
                            title: title,
                            body: body,
                            receivedAt: timestamp.dateValue()
                        )
                    }
                    print("🔔 AlarmFeature - 파싱된 알림 수: \(items.count)")
                    await send(.notificationsLoaded(items))
                } catch {
                    print("🔔 AlarmFeature - 에러: \(error)")
                    await send(.loadFailed(error.localizedDescription))
                }
            }

        case .notificationsLoaded(let items):
            state.isLoading = false
            state.notifications = items
            return .none

        case .loadFailed(let message):
            state.isLoading = false
            state.errorMessage = message
            return .none
        }
    }
}
