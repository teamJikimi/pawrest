//
//  CommunityAlarmSync.swift
//  pawrest
//
//  Created by Moon AYoung on 9/7/26.
//

import Foundation
import SwiftData

final class CommunityAlarmSync {
    static let shared = CommunityAlarmSync()
    private init() {}
    
    func sync(userID: String, context: ModelContext) async {
        let service = CommunityFirestoreService()
        
        guard let firestoreNotifs = try? await service.fetchNotifications(userID: userID)
        else { return }
        
        let existingIDs = Set(
            (try? context.fetch(FetchDescriptor<NotificationRecord>()))?.compactMap {
                $0.requestIdentifier
            } ?? []
        )
        
        for notif in firestoreNotifs {
            let requestID = "community_\(notif.type)_\(notif.id)"
            guard !existingIDs.contains(requestID) else { continue }
            
            let type = NotificationType(rawValue: notif.type) ?? .comment
            let record = NotificationRecord(
                type: type,
                title: type.displayTitle,
                body: notif.body,
                receivedAt: notif.createdAt,
                requestIdentifier: requestID,
                postID: notif.postID
            )
            record.isRead = notif.isRead
            context.insert(record)
        }
        
        try? context.save()
    }
}
