//
//  ProfileView.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 24/12/25.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    // Expect to use shared AuthViewModel for user and sign out
    @EnvironmentObject private var authVM: AuthViewModel
    @State private var showAddCategorySheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // Header with avatar and name
                header

                // Details
                VStack(spacing: 16) {
                    infoRow(title: "Full Name", value: fullName)
                    infoRow(title: "Email", value: email)
                    mobileRow
                    infoRow(title: "Currency", value: currencyDisplay)
                    categoryRow("Add Category")
                        .onTapGesture {
                            showAddCategorySheet = true
                        }
                }
                .padding()
                .background(Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Sign out button
                Button {
                    authVM.signOut()
                } label: {
                    Text("Sign Out")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.top, 8)

                Spacer(minLength: 40)
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Profile")
        .toolbarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddCategorySheet) {
            AddCategorySheet()
                .presentationDetents([.medium, .large])
                .presentationCornerRadius(16)
        }
    }

    // MARK: - Profile values
    private var firstName: String {
        authVM.userProfile?.firstName ?? ""
    }

    private var lastName: String {
        authVM.userProfile?.lastName ?? ""
    }

    private var fullName: String {
        let f = firstName.trimmingCharacters(in: .whitespaces)
        let l = lastName.trimmingCharacters(in: .whitespaces)
        let combined = [f, l].filter { !$0.isEmpty }.joined(separator: " ")
        return combined.isEmpty ? "—" : combined
    }

    private var email: String {
        authVM.user?.email ?? "—"
    }

    // Map the Firestore model (UserProfile.Country) into CountryData used by UI
    private var country: CountryData? {
        guard let c = authVM.userProfile?.country else { return nil }
        return CountryData(
            isoCode: c.isoCode,
            name: c.name,
            dialCode: c.dialCode,
            currencyName: c.currencyName
        )
    }

    private var mobile: String {
        authVM.userProfile?.mobile ?? ""
    }

    private var formattedMobile: String {
        guard !mobile.isEmpty else { return "—" }
        // Show as +<dial> <digits> (raw digits were saved from RegisterView)
        if country != nil {
            return "\(mobile)"
        } else {
            return mobile
        }
    }

    private var currencyDisplay: String {
        // Prefer the explicit currency field from profile; fall back to country currency name
        if let currency = authVM.userProfile?.currency, !currency.isEmpty {
            return currency
        }
        if let c = country {
            return c.currencyName
        }
        return "—"
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
            Text(title)
                .foregroundColor(.white.opacity(0.7))
            Spacer()
            Text(value)
                .foregroundColor(.white)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func categoryRow(_ title: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.white)
                .fontWeight(.bold)
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var mobileRow: some View {
        HStack {
            Text("Mobile")
                .foregroundColor(.white.opacity(0.7))
            Spacer()
            HStack(spacing: 6) {
                if let c = country {
                    Text(c.flag)
                    Text("+\(c.dialCode)")
                        .foregroundColor(.white.opacity(0.8))
                }
                Text(formattedMobile)
                    .foregroundColor(.white)
            }
            .lineLimit(1)
            .truncationMode(.tail)
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func initials(from name: String) -> String {
        let comps = name.split(separator: " ")
        let first = comps.first?.first.map(String.init) ?? ""
        let last = comps.dropFirst().first?.first.map(String.init) ?? ""
        let initials = (first + last)
        return initials.isEmpty ? "👤" : initials
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .preferredColorScheme(.dark)
            .environmentObject(AuthViewModel())
    }
}
