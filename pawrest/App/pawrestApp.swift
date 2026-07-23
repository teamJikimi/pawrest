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
            LetterModel.self
            AssessmentRecord.self,
            
            //스데 임시 연결
            UserProfile.self,
            PetProfile.self,
            NotificationRecord.self,
            AssessmentRecord.self

        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: [config])
    }()
    
    var body: some Scene {
        WindowGroup {
            AppView(store: Store(initialState: AppState()){
                AppReducer()
            })
        }
        .modelContainer(sharedModelContainer)
    }
}
