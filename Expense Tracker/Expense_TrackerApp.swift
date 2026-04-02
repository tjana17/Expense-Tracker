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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var biometricManager = BiometricLockManager()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ZStack {
                NavigationStack {
                    ContentView()
                        .preferredColorScheme(.dark)
                }
                .environmentObject(authVM)
                .environmentObject(biometricManager)

                // Overlay lock screen when locked
                if biometricManager.isLocked {
                    BiometricLockView()
                        .environmentObject(biometricManager)
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: biometricManager.isLocked)
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .background {
                    biometricManager.lockIfEnabled()
                }
            }
            .onAppear {
                // Lock on cold launch if enabled
                biometricManager.lockIfEnabled()
            }
        }
    }
}
