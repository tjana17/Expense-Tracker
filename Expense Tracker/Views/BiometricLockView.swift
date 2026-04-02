//
//  BiometricLockView.swift
//  Expense Tracker
//

import SwiftUI

struct BiometricLockView: View {
    @EnvironmentObject private var biometricManager: BiometricLockManager

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // App icon placeholder
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 100, height: 100)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.9))
                }

                VStack(spacing: 8) {
                    Text("Expense Tracker")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Text("App is locked")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                }

                // Error message if auth failed
                if let error = biometricManager.authError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                Spacer()

                // Unlock button
                Button {
                    biometricManager.authenticate()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: biometricManager.biometryTypeName == "Face ID"
                              ? "faceid"
                              : "touchid")
                        Text("Unlock with \(biometricManager.biometryTypeName)")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            // Auto-trigger authentication when lock screen appears
            biometricManager.authenticate()
        }
    }
}

#Preview {
    BiometricLockView()
        .environmentObject(BiometricLockManager())
}
