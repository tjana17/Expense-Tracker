//
//  RegisterView.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 03/12/25.
//

import SwiftUI
import Combine

struct RegisterView: View {
    
    @StateObject private var vm = RegisterViewModel()
    
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Create your account")
                    .font(.title.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.white)
                
                Group {
                    HStack(spacing: 12) {
                        textField("First Name", text: $vm.firstName)
                        textField("Last Name", text: $vm.lastName)
                    }
                    if vm.showValidation, let e = vm.firstNameError { fieldError(e) }
                    if vm.showValidation, let e = vm.lastNameError { fieldError(e) }
                    
                    textField("Email Address", text: $vm.email, keyboard: .emailAddress, textContentType: .emailAddress)
                        .autocapitalization(.none)
                        .textInputAutocapitalization(.never)
                    if vm.showValidation, let e = vm.emailError { fieldError(e) }
                    
                    // Mobile with country code picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mobile Number")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                        
                        HStack(spacing: 8) {
                            Menu {
                                ForEach(CountryData.all, id: \.isoCode) { c in
                                    Button {
                                        vm.selectedCountry = c
                                        if vm.currency.isEmpty {
                                            vm.currency = c.currencyName
                                        }
                                    } label: {
                                        HStack {
                                            Text(c.flag)
                                            Text(c.name)
                                            Spacer()
                                            Text("+\(c.dialCode)")
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Text(vm.selectedCountry.flag)
                                    Text("+\(vm.selectedCountry.dialCode)")
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 10)
                                .background(adaptiveFieldBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            
                            // Formatted mobile TextField (e.g., 123-456-7890)
                            TextField("Mobile Number", text: formattedMobileBinding)
                                .keyboardType(.numberPad)
                                .textContentType(.telephoneNumber)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 12)
                                .background(adaptiveFieldBackground)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .onChange(of: vm.mobile) { _, newValue in
                                    // still clamp raw digits to a practical length (e.g., 12)
                                    if newValue.count > 12 {
                                        vm.mobile = String(newValue.prefix(12))
                                    }
                                }
                        }
                    }
                    if vm.showValidation, let e = vm.mobileError { fieldError(e) }
                    
                    // Currency picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Currency Type")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Menu {
                            ForEach(CountryData.all, id: \.isoCode) { c in
                                Button {
                                    vm.currency = c.currencyName
                                } label: {
                                    HStack {
                                        Text(c.flag)
                                        Text(c.name)
                                        Spacer()
                                        Text(c.currencyName)
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(vm.currency.isEmpty ? "Select currency" : vm.currency)
                                    .foregroundColor(.white.opacity(vm.currency.isEmpty ? 0.6 : 1.0))
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            .background(adaptiveFieldBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    if vm.showValidation, let e = vm.currencyError { fieldError(e) }
                    
                    // Password with strength indicator
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Group {
                                if showPassword {
                                    textField("Password", text: $vm.password, isSecure: false)
                                } else {
                                    secureField("Password", text: $vm.password)
                                }
                            }
                            .textContentType(.newPassword)
                            
                            Button {
                                showPassword.toggle()
                            } label: {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        PasswordStrengthView(score: vm.passwordStrengthScore, description: vm.passwordStrengthDescription)
                    }
                    if vm.showValidation, let e = vm.passwordError { fieldError(e) }
                    
                    // Confirm password
                    HStack {
                        Group {
                            if showConfirmPassword {
                                textField("Confirm Password", text: $vm.confirmPassword, isSecure: false)
                            } else {
                                secureField("Confirm Password", text: $vm.confirmPassword)
                            }
                        }
                        .textContentType(.newPassword)
                        
                        Button {
                            showConfirmPassword.toggle()
                        } label: {
                            Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                .foregroundColor(.secondary)
                        }
                    }
                    if vm.showValidation, let e = vm.confirmPasswordError { fieldError(e) }
                }
                
                Button {
                    Task { await submit() }
                } label: {
                    HStack {
                        if vm.isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                        Text("Register")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(vm.isFormValid ? Color.blue : Color.gray.opacity(0.5))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!vm.isFormValid || vm.isSubmitting)
                .padding(.top, 8)
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .contentShape(Rectangle())
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .navigationTitle("Register")
        .toolbarTitleDisplayMode(.inline)
        .tint(.white)
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK") {
                // Dismiss RegisterView and go back to LoginView
                dismiss()
            }
        } message: {
            Text(alertMessage)
        }
        .onChange(of: vm.firstName) { _, _ in vm.userInteractedAndValidate() }
        .onChange(of: vm.lastName) { _, _ in vm.userInteractedAndValidate() }
        .onChange(of: vm.email) { _, _ in vm.userInteractedAndValidate() }
        .onChange(of: vm.selectedCountry) { _, _ in vm.userInteractedAndValidate() }
        .onChange(of: vm.mobile) { _, _ in vm.userInteractedAndValidate() }
        .onChange(of: vm.currency) { _, _ in vm.userInteractedAndValidate() }
        .onChange(of: vm.password) { _, _ in vm.userInteractedAndValidate() }
        .onChange(of: vm.confirmPassword) { _, _ in vm.userInteractedAndValidate() }
    }
    
    private var adaptiveFieldBackground: Color {
        // Same look for both light and dark
        Color.white.opacity(0.08)
    }
    
    private func submit() async {
        vm.showValidation = true
        vm.validateAll()
        guard vm.isFormValid else { return }
        
        vm.isSubmitting = true
        defer { vm.isSubmitting = false }
        
        // Call Firebase sign up through AuthViewModel
        let email = vm.email.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = vm.password
        
        await withCheckedContinuation { continuation in
//            authVM.signUp(email: email, password: password)
            // Since your AuthViewModel uses completion handlers and doesn’t expose result,
            // we’ll just show a success alert after a short delay if isSignedIn flips true.
            authVM.createUserWithProfile(email: email, password: password, firstName: vm.firstName, lastName: vm.lastName, mobileDigitsOnly: vm.mobile, country: vm.selectedCountry, currency: vm.currency) {_ in 
                print("User profile updated successfully..!")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                if authVM.isRegistered {
                    alertTitle = "Success"
                    alertMessage = "Account created successfully."
                } else {
                    alertTitle = "Sign Up"
                    alertMessage = "Please check your details and try again."
                }
                showAlert = true
                continuation.resume()
            }
        }
    }
    
    private func textField(_ title: String, text: Binding<String>, keyboard: UIKeyboardType = .default, textContentType: UITextContentType? = nil, isSecure: Bool = false) -> some View {
        TextField(title, text: text)
            .textContentType(textContentType)
            .keyboardType(keyboard)
            .autocorrectionDisabled(true)
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(adaptiveFieldBackground)
            .foregroundColor(.white)
            .tint(.white) // caret and accent
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private func secureField(_ title: String, text: Binding<String>) -> some View {
        SecureField(title, text: text)
            .autocorrectionDisabled(true)
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(adaptiveFieldBackground)
            .foregroundColor(.white)
            .tint(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private func fieldError(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .foregroundColor(.red)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Mobile formatting binding
private extension RegisterView {
    // Proxy binding that formats vm.mobile (digits-only) as XXX-XXX-XXXX for display
    var formattedMobileBinding: Binding<String> {
        Binding<String>(
            get: {
                formatPhone(vm.mobile)
            },
            set: { newValue in
                // Strip non-digits from user input
                let digits = newValue.filter { $0.isNumber }
                // Optionally clamp to 10 digits for US-style formatting; or allow more (e.g., 12)
                let clamped = String(digits.prefix(12))
                vm.mobile = clamped
            }
        )
    }
    
    func formatPhone(_ digits: String) -> String {
        let d = digits.filter { $0.isNumber }
        let count = d.count
        if count == 0 { return "" }
        let chars = Array(d)
        
        // Format as XXX-XXX-XXXX (US-style) progressively
        if count <= 3 {
            return String(chars[0..<count])
        } else if count <= 6 {
            let part1 = String(chars[0..<3])
            let part2 = String(chars[3..<count])
            return "\(part1)-\(part2)"
        } else {
            let part1 = String(chars[0..<3])
            let part2 = String(chars[3..<6])
            let part3 = String(chars[6..<min(10, count)])
            return "\(part1)-\(part2)-\(part3)"
        }
    }
}

#Preview {
    NavigationStack {
        RegisterView()
            .preferredColorScheme(.dark)
    }
}
