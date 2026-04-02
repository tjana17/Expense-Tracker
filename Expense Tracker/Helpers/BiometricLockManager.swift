//
//  BiometricLockManager.swift
//  Expense Tracker
//

import Foundation
import LocalAuthentication
import SwiftUI
import Combine

@MainActor
final class BiometricLockManager: ObservableObject {

    @Published var isLocked: Bool = false
    @Published var authError: String? = nil

    /// Persisted preference — whether biometric lock is enabled
    @AppStorage("biometricLockEnabled") var isEnabled: Bool = false

    // MARK: - Lock / Unlock

    /// Call when the app moves to background or on cold launch if enabled
    func lockIfEnabled() {
        if isEnabled {
            isLocked = true
        }
    }

    /// Trigger Face ID / Touch ID authentication
    func authenticate() {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            authError = error?.localizedDescription ?? "Biometrics not available on this device."
            return
        }

        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Unlock Expense Tracker"
        ) { success, evaluationError in
            Task { @MainActor in
                if success {
                    withAnimation {
                        self.isLocked = false
                    }
                    self.authError = nil
                } else {
                    self.authError = evaluationError?.localizedDescription ?? "Authentication failed."
                }
            }
        }
    }

    /// Toggle the lock setting.
    /// When enabling: prompts Face ID/Touch ID first — only saves preference on success.
    /// When disabling: clears immediately.
    func setEnabled(_ enabled: Bool) {
        authError = nil

        guard enabled else {
            isEnabled = false
            return
        }

        let context = LAContext()
        var nsError: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &nsError) else {
            authError = nsError?.localizedDescription ?? "Face ID / Touch ID is not available on this device."
            return
        }

        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Confirm your identity to enable biometric lock"
        ) { success, evaluationError in
            Task { @MainActor in
                if success {
                    self.isEnabled = true
                    self.authError = nil
                } else {
                    // Authentication failed or cancelled — keep toggle OFF
                    self.isEnabled = false
                    if let err = evaluationError as? LAError, err.code != .userCancel {
                        self.authError = evaluationError?.localizedDescription
                    }
                }
            }
        }
    }

    var biometryTypeName: String {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        default: return "Biometrics"
        }
    }
}
