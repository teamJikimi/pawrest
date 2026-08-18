//
//  pawrestApp.swift
//  pawrest
//
//  Created by Moon AYoung on 4/2/26.
//

import SwiftUI
import SwiftData
import FirebaseCore
import ComposableArchitecture

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions:
                     [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Task {
            _ = await NotificationService.shared.requestAuthorization()
            NotificationService.shared.scheduleEmotionReminders(enabled: UserDefaults.standard.bool(forKey: "emotionReminderEnabled"))
        }
        return true
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
            WeeklyReportCache.self,
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
        }
        .modelContainer(sharedModelContainer)
    }
}
