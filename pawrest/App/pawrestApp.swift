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

let sharedModelContainer: ModelContainer = {
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

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions:
                     [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        Task {
            let granted = await NotificationService.shared.requestAuthorization()
           
            if UserDefaults.standard.object(forKey: "emotionReminderEnabled") == nil {
                UserDefaults.standard.set(granted, forKey: "emotionReminderEnabled")
                NotificationService.shared.scheduleEmotionReminders(enabled: granted)
            }
            if UserDefaults.standard.object(forKey: "weeklyReportEnabled") == nil {
                UserDefaults.standard.set(granted, forKey: "weeklyReportEnabled")
            }
        }
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            for notification in notifications {
                AppDelegate.saveNotification(
                    notification.request.content,
                    identifier: notification.request.identifier
                )
            }
        }
        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 didReceive response: UNNotificationResponse,
                                 withCompletionHandler completionHandler: @escaping () -> Void) {
        saveNotification(response.notification.request.content, identifier: response.notification.request.identifier)
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification,
                                 withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        saveNotification(notification.request.content, identifier: notification.request.identifier)
        completionHandler([.banner, .sound])
    }

    static func saveNotification(_ content: UNNotificationContent, identifier: String) {
        let typeString = content.userInfo["type"] as? String ?? ""
        let notificationType: NotificationType = {
            switch typeString {
            case "emotionReminder": return .emotionReminder
            case "assessment": return .assessmentReminder
            case "anniversary": return .anniversary
            case "letter": return .memorialLetter
            case "comment": return .comment
            case "like": return .like
            default: return .emotionReminder
            }
        }()

        DispatchQueue.main.async {
            let context = sharedModelContainer.mainContext
            let fetch = FetchDescriptor<NotificationRecord>(
                predicate: #Predicate { $0.identifier == identifier }
            )
            let existing = try? context.fetch(fetch)
            guard existing?.isEmpty == true else { return }

            let record = NotificationRecord(
                identifier: identifier,
                type: notificationType,
                title: content.title,
                body: content.body
            )
            context.insert(record)
            try? context.save()
        }
    }

    private func saveNotification(_ content: UNNotificationContent, identifier: String) {
        AppDelegate.saveNotification(content, identifier: identifier)
    }
}

@main
struct pawrestApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) private var scenePhase

    let store: StoreOf<AppReducer> = {
        var state = AppState()
        let context = ModelContext(sharedModelContainer)
        let users = try? context.fetch(FetchDescriptor<UserProfile>())
        state.destination = (users?.isEmpty == false) ? .tabBar : .splash
        return Store(initialState: state) { AppReducer() }
    }()

    var body: some Scene {
        WindowGroup {
            AppView(store: store)
                .preferredColorScheme(.light)
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
                    for notification in notifications {
                        AppDelegate.saveNotification(
                            notification.request.content,
                            identifier: notification.request.identifier
                        )
                    }
                }
            }
        }
    }
}
