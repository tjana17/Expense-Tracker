//
//  AuthViewModel.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 20/12/25.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

// MARK: - UserProfile model matching Firestore "users/{uid}"
struct UserProfile: Identifiable, Codable {
    var id: String { uid }
    let uid: String
    let email: String
    let firstName: String
    let lastName: String
    let mobile: String
    let country: Country
    let currency: String
    let createdAt: Date?
    let updatedAt: Date?

    struct Country: Codable {
        let isoCode: String
        let name: String
        let dialCode: String
        let currencyName: String
    }

    // Manual init from Firestore dictionary
    init?(uid: String, dict: [String: Any]) {
        guard
            let email = dict["email"] as? String,
            let firstName = dict["firstName"] as? String,
            let lastName = dict["lastName"] as? String,
            let mobile = dict["mobile"] as? String,
            let currency = dict["currency"] as? String
        else { return nil }

        var created: Date? = nil
        var updated: Date? = nil
        if let ts = dict["createdAt"] as? Timestamp {
            created = ts.dateValue()
        }
        if let ts = dict["updatedAt"] as? Timestamp {
            updated = ts.dateValue()
        }

        var countryModel = Country(isoCode: "", name: "", dialCode: "", currencyName: "")
        if let c = dict["country"] as? [String: Any] {
            let iso = c["isoCode"] as? String ?? ""
            let name = c["name"] as? String ?? ""
            let dial = c["dialCode"] as? String ?? ""
            let currName = c["currencyName"] as? String ?? ""
            countryModel = Country(isoCode: iso, name: name, dialCode: dial, currencyName: currName)
        }

        self.uid = uid
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.mobile = mobile
        self.country = countryModel
        self.currency = currency
        self.createdAt = created
        self.updatedAt = updated
    }

    // Convenience initializer for local construction (optimistic assignment)
    init(
        uid: String,
        email: String,
        firstName: String,
        lastName: String,
        mobile: String,
        country: Country,
        currency: String,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.uid = uid
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.mobile = mobile
        self.country = country
        self.currency = currency
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

class AuthViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var isSignedIn: Bool = false
    @Published var isRegistered: Bool = false
    @Published var lastErrorMessage: String? = nil

    // Published profile loaded from Firestore
    @Published var userProfile: UserProfile? = nil

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    init() {
        self.user = Auth.auth().currentUser
        self.isSignedIn = user != nil

        // Optionally auto-fetch profile if already signed in
        if let uid = user?.uid {
            getUserDetails(for: uid)
        }
    }

    // Simple sign up (auth only)
    func signUp(email: String, password: String) {
        lastErrorMessage = nil
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.lastErrorMessage = error.localizedDescription
                print("Sign Up Error: \(error.localizedDescription)")
                return
            }
            self.user = result?.user
            self.isRegistered = true
        }
    }

    // Full flow: create auth user, then store profile in Firestore
    func createUserWithProfile(
        email: String,
        password: String,
        firstName: String,
        lastName: String,
        mobileDigitsOnly: String,
        country: CountryData,
        currency: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        lastErrorMessage = nil
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.lastErrorMessage = error.localizedDescription
                print("Sign Up Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let uid = result?.user.uid else {
                let err = NSError(domain: "AuthViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing user id"])
                self.lastErrorMessage = err.localizedDescription
                print("Auth user missing uid after createUser")
                completion(.failure(err))
                return
            }

            self.user = result?.user
            self.isRegistered = true

            // Build profile payload
            let payload: [String: Any] = [
                "uid": uid,
                "email": email,
                "firstName": firstName,
                "lastName": lastName,
                "mobile": mobileDigitsOnly,
                "country": [
                    "isoCode": country.isoCode,
                    "name": country.name,
                    "dialCode": country.dialCode,
                    "currencyName": country.currencyName
                ],
                "currency": currency,
                "createdAt": FieldValue.serverTimestamp(),
                "updatedAt": FieldValue.serverTimestamp()
            ]

            // Write to users/{uid}
            self.db.collection("users").document(uid).setData(payload, merge: false) { err in
                if let err = err {
                    self.lastErrorMessage = err.localizedDescription
                    print("Firestore Write Error: \(err.localizedDescription)")
                    completion(.failure(err))
                    return
                }
                print("Firestore Write Success for uid: \(uid)")

                // Optimistically populate userProfile locally
                let countryModel = UserProfile.Country(
                    isoCode: country.isoCode,
                    name: country.name,
                    dialCode: country.dialCode,
                    currencyName: country.currencyName
                )
                self.userProfile = UserProfile(
                    uid: uid,
                    email: email,
                    firstName: firstName,
                    lastName: lastName,
                    mobile: mobileDigitsOnly,
                    country: countryModel,
                    currency: currency,
                    createdAt: nil,
                    updatedAt: nil
                )

                // Also start listening to the document for live updates
                self.getUserDetails(for: uid)

                completion(.success(()))
                if let uid = result?.user.uid {
                    self.getUserDetails(for: uid)
                }
            }
        }
    }

    func signIn(email: String, password: String) {
        lastErrorMessage = nil
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.lastErrorMessage = error.localizedDescription
                print("Sign In Error: \(error.localizedDescription)")
                return
            }
            self.user = result?.user
            self.isSignedIn = true

            if let uid = result?.user.uid {
                self.getUserDetails(for: uid)
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.isSignedIn = false
            self.isRegistered = false
            self.userProfile = nil
            // Remove any active Firestore listener
            listener?.remove()
            listener = nil
            print("Signout successful")
        } catch {
            lastErrorMessage = error.localizedDescription
            print("Sign Out Error: \(error.localizedDescription)")
        }
    }

    // MARK: - Load current user's profile
    // Public convenience: fetch for current user
    func getUserDetails() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.lastErrorMessage = "No authenticated user"
            self.userProfile = nil
            // Remove listener if any
            listener?.remove()
            listener = nil
            return
        }
        getUserDetails(for: uid)
    }

    // Private: set up a snapshot listener for users/{uid}
    private func getUserDetails(for uid: String) {
        // Remove old listener to avoid duplicates
        listener?.remove()
        listener = db.collection("users").document(uid).addSnapshotListener { snapshot, error in
            if let error = error {
                self.lastErrorMessage = error.localizedDescription
                print("Fetch Profile Error: \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot, let data = snapshot.data() else {
                self.userProfile = nil
                return
            }
            if let profile = UserProfile(uid: uid, dict: data) {
                self.userProfile = profile
            } else {
                self.lastErrorMessage = "Failed to parse user profile"
                print("Failed to parse user profile for uid: \(uid)")
            }
        }
    }
}
