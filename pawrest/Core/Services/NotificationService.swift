//
//  NotificationService.swift
//  pawrest
//
//  Created by 소은 on 6/12/26.
//


// TODO: FCM 연동 후 아래 기능 구현 필요
// - AppDelegate에 FCM 수신 핸들러 추가
// - 댓글/좋아요 알림 수신 시 NotificationRecord SwiftData에 저장
// - 커뮤니티 반응 알림 (comment, like) 실시간 처리

import UserNotifications
import Foundation

final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
        return granted ?? false
    }

    func scheduleEmotionReminder(enabled: Bool) {
        let id = "emotion_reminder"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        guard enabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "감정 기록"
        content.body = "오늘 하루는 어떠셨나요? 감정을 기록해보세요."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 21
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func scheduleAssessmentReminder(lastAssessmentDate: Date) {
        let id = "assessment_reminder"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])

        guard let fireDate = Calendar.current.date(byAdding: .month, value: 3, to: lastAssessmentDate),
              fireDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "심리 검사"
        content.body = "마지막 자가진단이 3달 전이에요. 지금 상태를 한번 확인해볼까요?"
        content.sound = .default

        let interval = fireDate.timeIntervalSinceNow
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func scheduleAnniversaryReminder(petName: String, anniversaryDate: Date, enabled: Bool) {
        let id = "anniversary_reminder"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        guard enabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "기일"
        content.body = "\(petName)의 기일이에요. 편지를 보내볼까요?"
        content.sound = .default

        var components = Calendar.current.dateComponents([.month, .day], from: anniversaryDate)
        components.hour = 10
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func scheduleLetterDelivery(letterId: String) {
        let id = "letter_\(letterId)"
        let content = UNMutableNotificationContent()
        content.title = "추모 편지"
        content.body = "오늘의 편지가 무지개 다리 너머로 전달됐어요."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60 * 60 * 24, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
