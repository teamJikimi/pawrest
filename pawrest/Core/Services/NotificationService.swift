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
// - 로그인 끝나면 로컬데이터에 petName 저장해서 기일에 알림 뜨도록


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
    
    // scheduleEmotionReminders는 64일치만 예약되므로 앱 실행 시 남은 알림이 적으면 자동으로 재스케줄링 필요함 .. 일단 이렇게 해둠
    func scheduleEmotionReminders(enabled: Bool) {
        let ids = (0..<64).map { "emotion_reminder_\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        guard enabled else { return }

        let calendar = Calendar.current
        for day in 0..<64 {
            guard let date = calendar.date(byAdding: .day, value: day, to: Date()) else { continue }
            var components = calendar.dateComponents([.year, .month, .day], from: date)
            components.hour = 21
            components.minute = 0

            let content = UNMutableNotificationContent()
            content.title = "감정 기록"
            content.body = "오늘 하루는 어떠셨나요? 감정을 기록해보세요."
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: "emotion_reminder_\(day)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }

    func cancelTodayEmotionReminder() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let calendar = Calendar.current
            let todayIds = requests
                .filter { $0.identifier.hasPrefix("emotion_reminder_") }
                .filter { request in
                    guard let trigger = request.trigger as? UNCalendarNotificationTrigger,
                          let fireDate = trigger.nextTriggerDate() else { return false }
                    return calendar.isDateInToday(fireDate)
                }
                .map { $0.identifier }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: todayIds)
        }
    }

    func scheduleAssessmentReminder(lastAssessmentDate: Date?, enabled: Bool) {
        let id = "assessment_reminder"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])

        guard enabled,
              let lastDate = lastAssessmentDate,
              let fireDate = Calendar.current.date(byAdding: .month, value: 3, to: lastDate),
              fireDate > Date() else { return }

        var components = Calendar.current.dateComponents([.year, .month, .day], from: fireDate)
        components.hour = 20
        components.minute = 0
        components.second = 0

        let content = UNMutableNotificationContent()
        content.title = "심리 검사"
        content.body = "마지막 자가진단이 3달 전이에요. 지금 상태를 한번 확인해볼까요?"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
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

    //TODO: - 편지 보내기 버튼에 호출 코드 추가
    //  편지 작성 화면에서 저장 버튼 누를 때 이렇게 호출  NotificationService.shared.scheduleLetterDelivery(letterId: UUID().uuidString)
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
