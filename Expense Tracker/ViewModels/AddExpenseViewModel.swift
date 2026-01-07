//
//  AddExpenseViewModel.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 07/01/26.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import Combine

@MainActor
final class AddExpenseViewModel: ObservableObject {

    private let db = Firestore.firestore()

    // Save an expense to Firestore under users/{userId}/expenses/{expenseId}
    func saveExpense(
        userId: String,
        categoryId: UUID,
        categoryName: String,
        categoryIcon: String,
        amount: Double,
        paymentType: String,
        date: Date
    ) async throws {
        let expenseId = UUID().uuidString

        let payload: [String: Any] = [
            "id": expenseId,
            "userId": userId,
            "categoryId": categoryId.uuidString,
            "categoryName": categoryName,
            "categoryIcon": categoryIcon,
            "amount": amount,
            "paymentType": paymentType,
            "date": Timestamp(date: date),
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            db.collection("expenses")
                .document(expenseId)
                .setData(payload, merge: false) { error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume()
                    }
                }
        }
    }
}

