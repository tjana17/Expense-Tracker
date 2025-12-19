//
//  ForgotPasswordSheet.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 19/12/25.
//

import SwiftUI

struct ForgotPasswordSheet: View {
    @Binding var email: String
    @Binding var error: String?
    var onSubmit: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
//            Capsule()
//                .fill(Color.secondary.opacity(0.4))
//                .frame(width: 44, height: 5)
//                .padding(.top, 8)
            
            Text("Reset Password")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Enter your account email. We’ll send you a password reset link.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(Color.secondary.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            if let error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity)
            }
            
            HStack {
                Button(action: onSubmit) {
                    Text("Submit").bold()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.top, 4)
        }
        .padding()
        .onAppear {
            // Clear the email and any prior error each time the sheet is presented
            email = ""
            error = nil
        }
    }
}
