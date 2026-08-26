//
//  pawrestApp.swift
//  pawrest
//
//  Created by Moon AYoung on 4/2/26.
//

import SwiftUI
import SwiftData
import FirebaseCore
import UserNotifications
import ComposableArchitecture

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var modelContainer: ModelContainer?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        Task {
            _ = await NotificationService.shared.requestAuthorization()
            NotificationService.shared.scheduleEmotionReminders(enabled: UserDefaults.standard.bool(forKey: "emotionReminderEnabled"))
        }
        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        saveNotification(notification.request.content)
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        saveNotification(response.notification.request.content)
        completionHandler()
    }

    private func saveNotification(_ content: UNNotificationContent) {
        guard let container = modelContainer else { return }
        let identifier = content.categoryIdentifier.isEmpty ? content.threadIdentifier : content.categoryIdentifier
        let type = notificationType(from: content.userInfo["type"] as? String ?? identifier)
        let context = ModelContext(container)
        let record = NotificationRecord(type: type, title: content.title, body: content.body)
        context.insert(record)
        try? context.save()
    }

    private func notificationType(from identifier: String) -> NotificationType {
        switch identifier {
        case "comment":    return .comment
        case "like":       return .like
        case "letter":     return .memorialLetter
        case "anniversary": return .anniversary
        case "assessment": return .assessmentReminder
        default:           return .emotionReminder
        }
    }
}

@main
struct pawrestApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            MemoryModel.self,
            EmotionRecordModel.self,
            LetterModel.self,
            AssessmentRecord.self,
            UserProfile.self,
            PetProfile.self,
            NotificationRecord.self,
            WeeklyReportCache.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: [config])
    }()

    var initialAppState: AppState {
        var state = AppState()
        let context = ModelContext(sharedModelContainer)
        let descriptor = FetchDescriptor<UserProfile>()
        let users = try? context.fetch(descriptor)
        state.destination = (users?.isEmpty == false) ? .tabBar : .splash
        return state
    }

    var body: some Scene {
        WindowGroup {
            AppView(store: Store(initialState: initialAppState) {
                AppReducer()
            })
            .preferredColorScheme(.light)
            .onAppear {
                delegate.modelContainer = sharedModelContainer
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
