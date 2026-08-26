//
//  NotificationRecord.swift
//  pawrest
//
//  Created by 소은 on 6/12/26.
//

import SwiftData
import Foundation

@Model
final class NotificationRecord {
    var id: UUID
    var type: String
    var title: String
    var body: String
    var receivedAt: Date
    var isRead: Bool

    init(type: NotificationType, title: String, body: String, receivedAt: Date = Date()) {
        self.id = UUID()
        self.type = type.rawValue
        self.title = title
        self.body = body
        self.receivedAt = receivedAt
        self.isRead = false
    }

    var notificationType: NotificationType {
        NotificationType(rawValue: type) ?? .emotionReminder
    }
}

enum NotificationType: String {
    case comment
    case like
    case memorialLetter
    case anniversary
    case assessmentReminder
    case emotionReminder

    var iconName: String {
        switch self {
        case .comment:            return "icon_alarm_comment"
        case .like:               return "icon_alarm_like"
        case .memorialLetter:     return "icon_alarm_letter"
        case .anniversary:        return "icon_alarm_anniversary"
        case .assessmentReminder: return "icon_alarm_assessment"
        case .emotionReminder:    return "icon_alarm_emotion"
        }
    }

    var displayTitle: String {
        switch self {
        case .comment:            return "댓글"
        case .like:               return "좋아요"
        case .memorialLetter:     return "추모 편지"
        case .anniversary:        return "기일"
        case .assessmentReminder: return "심리 검사"
        case .emotionReminder:    return "감정 기록"
        }
    }
}
