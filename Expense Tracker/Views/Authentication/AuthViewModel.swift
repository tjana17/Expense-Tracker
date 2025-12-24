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

class AuthViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var isSignedIn: Bool = false
    @Published var isRegistered: Bool = false
    @Published var lastErrorMessage: String? = nil

    private let db = Firestore.firestore()

    init() {
        self.user = Auth.auth().currentUser
        self.isSignedIn = user != nil
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
            self.db.collection("users").document(uid).setData(payload) { err in
                if let err = err {
                    self.lastErrorMessage = err.localizedDescription
                    print("Firestore Write Error: \(err.localizedDescription)")
                    completion(.failure(err))
                    return
                }
                print("Firestore Write Success for uid: \(uid)")
                completion(.success(()))
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
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.isSignedIn = false
            print("Signout successful")
        } catch {
            lastErrorMessage = error.localizedDescription
            print("Sign Out Error: \(error.localizedDescription)")
        }
    }
}
