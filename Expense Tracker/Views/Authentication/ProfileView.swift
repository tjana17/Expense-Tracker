//
//  ProfileView.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 24/12/25.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @EnvironmentObject private var biometricManager: BiometricLockManager
    @State private var showEditProfile = false
    @State private var showChangePassword = false
    @State private var showSignOutAlert = false

    // Toast state
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var toastStyle: ToastStyle = .success

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                header

                VStack(spacing: 16) {
                    infoRow(title: "Full Name", value: fullName)
                    infoRow(title: "Email", value: email)
                    mobileRow
                    infoRow(title: "Currency", value: currencyDisplay)
                }
                .padding()
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Action buttons
                VStack(spacing: 12) {
                    actionButton(title: "Edit Profile", icon: "pencil", color: .blue) {
                        showEditProfile = true
                    }
                    actionButton(title: "Change Password", icon: "lock.rotation", color: .orange) {
                        showChangePassword = true
                    }

                    // Biometric lock toggle
                    HStack {
                        Image(systemName: biometricManager.biometryTypeName == "Face ID" ? "faceid" : "touchid")
                            .foregroundColor(.purple)
                        Text("\(biometricManager.biometryTypeName) Lock")
                            .bold()
                            .foregroundColor(.white)
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { biometricManager.isEnabled },
                            set: { biometricManager.setEnabled($0) }
                        ))
                        .labelsHidden()
                        .tint(.purple)
                    }
                    .padding()
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    if let error = biometricManager.authError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal, 4)
                    }

                    actionButton(title: "Sign Out", icon: "rectangle.portrait.and.arrow.right", color: .red) {
                        showSignOutAlert = true
                    }
                }
                .padding(.top, 8)

                Spacer(minLength: 40)
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Profile")
        .toolbarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEditProfile) {
            EditProfileSheet(
                onSave: { msg in
                    toastMessage = msg
                    toastStyle = .success
                    showToast = true
                },
                onError: { msg in
                    toastMessage = msg
                    toastStyle = .error
                    showToast = true
                }
            )
        }
        .sheet(isPresented: $showChangePassword) {
            ChangePasswordSheet(
                onSuccess: {
                    toastMessage = "Password changed successfully"
                    toastStyle = .success
                    showToast = true
                },
                onError: { msg in
                    toastMessage = msg
                    toastStyle = .error
                    showToast = true
                }
            )
        }
        .toast(isPresented: $showToast, message: toastMessage, style: toastStyle)
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Sign Out", role: .destructive) {
                authVM.signOut()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to sign out of your account?")
        }
    }

    // MARK: - Profile values
    private var firstName: String { authVM.userProfile?.firstName ?? "" }
    private var lastName: String { authVM.userProfile?.lastName ?? "" }

    private var fullName: String {
        let f = firstName.trimmingCharacters(in: .whitespaces)
        let l = lastName.trimmingCharacters(in: .whitespaces)
        let combined = [f, l].filter { !$0.isEmpty }.joined(separator: " ")
        return combined.isEmpty ? "—" : combined
    }

    private var email: String { authVM.user?.email ?? "—" }

    private var country: CountryData? {
        guard let c = authVM.userProfile?.country else { return nil }
        return CountryData(isoCode: c.isoCode, name: c.name, dialCode: c.dialCode, currencyName: c.currencyName)
    }

    private var mobile: String { authVM.userProfile?.mobile ?? "" }

    private var formattedMobile: String {
        guard !mobile.isEmpty else { return "—" }
        return mobile
    }

    private var currencyDisplay: String {
        if let currency = authVM.userProfile?.currency, !currency.isEmpty { return currency }
        return country?.currencyName ?? "—"
    }

    // MARK: - Subviews
    private var header: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 64, height: 64)
                Text(initials(from: fullName))
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(fullName)
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text(email)
                    .foregroundColor(.white.opacity(0.7))
                    .font(.subheadline)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }

            Spacer()
        }
    }

    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title).foregroundColor(.white.opacity(0.7))
            Spacer()
            Text(value).foregroundColor(.white).lineLimit(1).truncationMode(.tail)
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var mobileRow: some View {
        HStack {
            Text("Mobile").foregroundColor(.white.opacity(0.7))
            Spacer()
            HStack(spacing: 6) {
                if let c = country {
                    Text(c.flag)
                    Text("+\(c.dialCode)").foregroundColor(.white.opacity(0.8))
                }
                Text(formattedMobile).foregroundColor(.white)
            }
            .lineLimit(1).truncationMode(.tail)
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func actionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon).foregroundColor(color)
                Text(title).bold().foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.white.opacity(0.4))
            }
            .padding()
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func initials(from name: String) -> String {
        let comps = name.split(separator: " ")
        let first = comps.first?.first.map(String.init) ?? ""
        let last = comps.dropFirst().first?.first.map(String.init) ?? ""
        let initials = first + last
        return initials.isEmpty ? "?" : initials
    }
}

// MARK: - Edit Profile Sheet
struct EditProfileSheet: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    var onSave: (String) -> Void
    var onError: (String) -> Void

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var mobile: String = ""
    @State private var selectedCountry: CountryData = CountryData.defaultCountry
    @State private var showCountryPicker = false
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    fieldLabel("First Name")
                    inputField("First Name", text: $firstName)

                    fieldLabel("Last Name")
                    inputField("Last Name", text: $lastName)

                    fieldLabel("Mobile")
                    inputField("Mobile number", text: $mobile, keyboardType: .phonePad)

                    fieldLabel("Country & Currency")
                    Button {
                        showCountryPicker = true
                    } label: {
                        HStack {
                            Text(selectedCountry.flag)
                            Text(selectedCountry.name)
                                .foregroundColor(.white)
                            Spacer()
                            Text(selectedCountry.currencyName)
                                .foregroundColor(.white.opacity(0.6))
                                .font(.caption)
                            Image(systemName: "chevron.down")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    Spacer(minLength: 20)

                    Button {
                        Task { await save() }
                    } label: {
                        if isSaving {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        } else {
                            Text("Save Changes")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                    }
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .disabled(isSaving)
                }
                .padding()
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showCountryPicker) {
                countryPickerSheet
            }
            .onAppear { prefill() }
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 16).weight(.semibold))
            .foregroundColor(.white.opacity(0.8))
    }

    private func inputField(_ placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        TextField(placeholder, text: text)
            .keyboardType(keyboardType)
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .foregroundColor(.white)
    }

    private var countryPickerSheet: some View {
        NavigationStack {
            List(CountryData.all, id: \.isoCode) { country in
                Button {
                    selectedCountry = country
                    showCountryPicker = false
                } label: {
                    HStack {
                        Text(country.flag)
                        Text(country.name).foregroundColor(.white)
                        Spacer()
                        Text(country.currencyName).foregroundColor(.secondary).font(.caption)
                        if selectedCountry.isoCode == country.isoCode {
                            Image(systemName: "checkmark").foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Select Country")
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.dark)
    }

    private func prefill() {
        firstName = authVM.userProfile?.firstName ?? ""
        lastName = authVM.userProfile?.lastName ?? ""
        mobile = authVM.userProfile?.mobile ?? ""
        if let c = authVM.userProfile?.country,
           let match = CountryData.all.first(where: { $0.isoCode == c.isoCode }) {
            selectedCountry = match
        }
    }

    private func save() async {
        isSaving = true
        defer { isSaving = false }
        do {
            try await authVM.updateProfile(
                firstName: firstName.trimmingCharacters(in: .whitespaces),
                lastName: lastName.trimmingCharacters(in: .whitespaces),
                mobile: mobile.trimmingCharacters(in: .whitespaces),
                currency: selectedCountry.currencyName,
                country: selectedCountry
            )
            onSave("Profile updated successfully")
            dismiss()
        } catch {
            onError(error.localizedDescription)
        }
    }
}

// MARK: - Change Password Sheet
struct ChangePasswordSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authVM: AuthViewModel

    var onSuccess: () -> Void
    var onError: (String) -> Void

    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var isSaving = false
    @State private var showCurrent = false
    @State private var showNew = false
    @State private var showConfirm = false

    private var canSubmit: Bool {
        !currentPassword.isEmpty && newPassword.count >= 6 && newPassword == confirmPassword
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {

                fieldLabel("Current Password")
                passwordField("Enter current password", text: $currentPassword, show: $showCurrent)

                fieldLabel("New Password")
                passwordField("At least 6 characters", text: $newPassword, show: $showNew)

                fieldLabel("Confirm New Password")
                passwordField("Repeat new password", text: $confirmPassword, show: $showConfirm)

                if !confirmPassword.isEmpty && newPassword != confirmPassword {
                    Text("Passwords do not match")
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Spacer()

                Button {
                    Task { await submit() }
                } label: {
                    if isSaving {
                        ProgressView().frame(maxWidth: .infinity).padding(.vertical, 14)
                    } else {
                        Text("Change Password")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                }
                .background(canSubmit ? Color.orange : Color.gray.opacity(0.4))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .disabled(!canSubmit || isSaving)
            }
            .padding()
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 16).weight(.semibold))
            .foregroundColor(.white.opacity(0.8))
    }

    private func passwordField(_ placeholder: String, text: Binding<String>, show: Binding<Bool>) -> some View {
        HStack {
            Group {
                if show.wrappedValue {
                    TextField(placeholder, text: text)
                } else {
                    SecureField(placeholder, text: text)
                }
            }
            .foregroundColor(.white)
            Button { show.wrappedValue.toggle() } label: {
                Image(systemName: show.wrappedValue ? "eye.slash" : "eye")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func submit() async {
        isSaving = true
        defer { isSaving = false }
        do {
            try await authVM.changePassword(currentPassword: currentPassword, newPassword: newPassword)
            onSuccess()
            dismiss()
        } catch {
            onError(error.localizedDescription)
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .preferredColorScheme(.dark)
            .environmentObject(AuthViewModel())
            .environmentObject(BiometricLockManager())
    }
}
