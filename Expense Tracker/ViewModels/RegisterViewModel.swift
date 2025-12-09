//
//  RegisterViewModel.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 09/12/25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - ViewModel

@MainActor
final class RegisterViewModel: ObservableObject {
    
    // MARK: - Init
    // Inputs
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var selectedCountry: CountryData = CountryData.defaultCountry
    @Published var mobile: String = ""
    @Published var currency: String = ""
    
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    // State
    @Published var isSubmitting: Bool = false
    @Published var submitResult: Result<Void, Error>?
    @Published var showValidation: Bool = false   // NEW: controls when errors are shown
    
    // Validation errors
    @Published var firstNameError: String?
    @Published var lastNameError: String?
    @Published var emailError: String?
    @Published var mobileError: String?
    @Published var currencyError: String?
    @Published var passwordError: String?
    @Published var confirmPasswordError: String?
    
    // Pure validity check: no side effects, no @Published mutation
    var isFormValid: Bool {
        let firstNameOk = !firstName.isEmpty
        let lastNameOk = !lastName.isEmpty
        
        let emailTrim = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailOk = !emailTrim.isEmpty && Self.isValidEmail(emailTrim)
        
        let mobileDigitsOnly = CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: mobile))
        let mobileOk = !mobile.isEmpty && mobileDigitsOnly && mobile.count >= 6
        
        let currencyOk = !currency.isEmpty
        
        let passwordOk: Bool = {
            guard !password.isEmpty else { return false }
            return PasswordStrength.score(for: password) >= 2
        }()
        
        let confirmOk = !confirmPassword.isEmpty && confirmPassword == password
        
        return firstNameOk &&
        lastNameOk &&
        emailOk &&
        mobileOk &&
        currencyOk &&
        passwordOk &&
        confirmOk &&
        !isSubmitting
    }
    
    var passwordStrengthScore: Int {
        PasswordStrength.score(for: password)
    }
    
    var passwordStrengthDescription: String {
        PasswordStrength.description(for: passwordStrengthScore)
    }
    
    // MARK: - Fuctions
    // Call when user edits any field
    func userInteractedAndValidate() {
        if !showValidation {
            showValidation = true
        }
        validateAll()
    }
    
    // This function mutates @Published error fields and should be called
    // in response to user actions/changes, not during view rendering.
    func validateAll() {
        firstNameError = firstName.isEmpty ? "First name is required" : nil
        lastNameError = lastName.isEmpty ? "Last name is required" : nil
        
        let emailTrim = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if emailTrim.isEmpty {
            emailError = "Email is required"
        } else if !Self.isValidEmail(emailTrim) {
            emailError = "Please enter a valid email address"
        } else {
            emailError = nil
        }
        
        if mobile.isEmpty {
            mobileError = "Mobile number is required"
        } else if !CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: mobile)) {
            mobileError = "Mobile number must contain digits only"
        } else if mobile.count < 9 {
            mobileError = "Mobile number seems too short"
        } else {
            mobileError = nil
        }
        
        currencyError = currency.isEmpty ? "Please select a currency" : nil
        
        passwordError = password.isEmpty ? "Password is required" : passwordStrengthScore < 2 ? "Password is too weak" : nil
        
        confirmPasswordError = confirmPassword.isEmpty ? "Please confirm your password" : confirmPassword != password ? "Passwords do not match" : nil
    }
    
    static func isValidEmail(_ email: String) -> Bool {
        let pattern =
        #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }
    
    func register() async {
        // Assume validation already run; run again defensively
        showValidation = true
        validateAll()
        guard isFormValid else { return }
        
        isSubmitting = true
        defer { isSubmitting = false }
        
        do {
            // Simulated success when Firebase is not available:
            try await Task.sleep(nanoseconds: 800_000_000)
            submitResult = .success(())
        } catch {
            submitResult = .failure(error)
        }
    }
}
