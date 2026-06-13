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
            EmotionRecordModel.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: [config])
    }()
    
    var body: some Scene {
        WindowGroup {
            TestRootView()
        }
        .modelContainer(sharedModelContainer)
    }
    
    struct TestRootView: View {
        @State private var isPresented = false
        
        var body: some View {
            NavigationStack {
                Button("검사 결과 열기") {
                    isPresented = true
                }
                .navigationDestination(isPresented: $isPresented) {
                    SelfAssessmentResultView(
                        store: Store(
                            initialState: SelfAssessmentResultState(
                                assessmentType: .pbq,
                                score: 30,
                                historyState: .noRecord
                            )
                        ) {
                            SelfAssessmentResultFeature()
                        }
                    )
                }
            }
        }
    }
}
