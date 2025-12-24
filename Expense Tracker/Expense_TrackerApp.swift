//
//  Expense_TrackerApp.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 30/11/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct Expense_TrackerApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authVM = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
                    .preferredColorScheme(.dark)
            }
            .environmentObject(authVM)
        }
    }
}
