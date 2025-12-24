//
//  LoginView.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 03/12/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isRegisterActive = false
    @State private var isForgotPasswordActive = false
    @State private var showPassword = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var emailWasEdited = false

    // Forgot password bottom sheet state
    @State private var forgotEmail: String = ""
    @State private var forgotError: String?
    
    // Use shared AuthViewModel from environment
    @EnvironmentObject private var authVM: AuthViewModel

    var emailIsValid: Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }
    
    private func isValidEmail(_ value: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return value.range(of: pattern, options: .regularExpression) != nil
    }

    var body: some View {
        NavigationStack {
            if authVM.isSignedIn {
                // You can replace this with your main app view
                ExpenseHomeView()
            } else {
                VStack(spacing: 24) {
                    Spacer()
                    
                    // Logo on top
                    Image("logo") // Replace with your asset name
                        .resizable()
                        .scaledToFit()
                        .frame(width: 110, height: 110)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 6)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Text("Welcome Back")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 16) {
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.08))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .onChange(of: email) { _, _ in
                                emailWasEdited = true
                            }
                        
                        if emailWasEdited && !email.isEmpty && !emailIsValid {
                            Text("Please enter a valid email address")
                                .font(.caption)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .transition(.opacity)
                        }
                        
                        HStack {
                            Group {
                                if showPassword {
                                    TextField("Password", text: $password)
                                } else {
                                    SecureField("Password", text: $password)
                                }
                            }
                            .textContentType(.password)
                            .autocorrectionDisabled(true)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.08))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            Button {
                                showPassword.toggle()
                            } label: {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack {
                            Spacer()
                            Button("Forgot password?") {
                                // Prime the sheet with current email if present
                                forgotEmail = email
                                forgotError = nil
                                isForgotPasswordActive = true
                            }
                            .foregroundColor(.blue)
                            .font(.callout)
                            .padding(.trailing, 4)
                        }
                    }
                    
                    Button {
                        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmedEmail.isEmpty,
                              !password.isEmpty,
                              emailIsValid else {
                            alertMessage = "Please enter a valid email and password."
                            showAlert = true
                            return
                        }
                        
                        // Call Firebase sign-in via AuthViewModel
                        authVM.signIn(email: trimmedEmail, password: password)
                        
                        // Since AuthViewModel uses completion handlers and doesn’t expose error,
                        // we peek at isSignedIn shortly after to show feedback.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            if authVM.isSignedIn {
                                alertMessage = "Signed in successfully."
                            } else {
                                alertMessage = "Sign in failed. Please check your credentials and try again."
                            }
                            showAlert = true
                        }
                    } label: {
                        Text("Login")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background((!emailIsValid || email.isEmpty || password.isEmpty) ? Color.gray.opacity(0.5) : Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.top, 8)
                    .disabled(email.isEmpty || password.isEmpty || !emailIsValid)
                    .alert("Login", isPresented: $showAlert) {
                        Button("OK") { }
                    } message: {
                        Text(alertMessage)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.white.opacity(0.7))
                        
                        Button("Register") {
                            isRegisterActive = true
                        }
                        .foregroundColor(.blue)
                        .bold()
                        .buttonStyle(.plain)
                    }
                    .font(.callout)
                    .padding(.bottom, 12)
                }
                
                .padding()
                .background(Color.black.ignoresSafeArea())
                // New API to present RegisterView
                .navigationDestination(isPresented: $isRegisterActive) {
                    RegisterView()
                }
                // Bottom sheet for Forgot Password
                .sheet(isPresented: $isForgotPasswordActive) {
                    ForgotPasswordSheet(
                        email: $forgotEmail,
                        error: $forgotError,
                        onSubmit: {
                            // Validate email and simulate submission
                            let trimmed = forgotEmail.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else {
                                forgotError = "Email is required"
                                return
                            }
                            guard isValidEmail(trimmed) else {
                                forgotError = "Please enter a valid email address"
                                return
                            }
                            // Simulate request and dismiss
                            forgotError = nil
                            isForgotPasswordActive = false
                            alertMessage = "Password reset link sent to \(trimmed)"
                            showAlert = true
                        }
                    )
                    .presentationDetents([.height(260), .medium])
                    .presentationBackground(.ultraThinMaterial)
                    .presentationCornerRadius(16)
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
