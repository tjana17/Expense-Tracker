//
//  CategoriesViewModel.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 01/01/26.
//

import Foundation
import SwiftUI
import Combine
import FirebaseFirestore

@MainActor
final class CategoriesViewModel: ObservableObject {
    @Published private(set) var categories: [Category] = []

    private let db = Firestore.firestore()

    // Validation: name must be at least 3 visible characters
    func isValidName(_ name: String) -> Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3
    }

    // Local in-memory add (existing behavior)
    func addCategory(name: String, iconName: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isValidName(trimmed) else { return false }

        // Avoid duplicates by name (case-insensitive)
        if categories.contains(where: { $0.name.lowercased() == trimmed.lowercased() }) {
            return false
        }

        let new = Category(name: trimmed, iconName: iconName)
        categories.append(new)
        return true
    }

    // Firestore: create a new category document in "category" collection
    // Returns the generated category id on success.
    func saveCategoryToFirestore(userId: String, name: String, iconName: String) async throws -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isValidName(trimmed) else {
            throw NSError(domain: "CategoriesViewModel",
                          code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid name"])
        }

        let categoryId = UUID().uuidString
        let payload: [String: Any] = [
            "id": categoryId,
            "userId": userId,
            "name": trimmed,
            "iconName": iconName,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            db.collection("category").document(categoryId).setData(payload, merge: false) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }

        // Optionally reflect locally as well
        let local = Category(id: UUID(uuidString: categoryId) ?? UUID(), name: trimmed, iconName: iconName)
        categories.append(local)

        return categoryId
    }
}
