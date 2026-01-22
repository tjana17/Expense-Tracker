//
//  FirestoreManager.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 21/01/26.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    
    // MARK: - Public Func
    func getCurrentMonth() -> (start: Date, end: Date) {
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date) // January = 1 in Swift

        let components = DateComponents(year: year, month: month, day: 1)
        let start = calendar.date(from: components)!
        let end = calendar.date(byAdding: .month, value: 1, to: start)!
        Log.info("Year - \(year), Month - \(month)")
        return (start, end)
    }
    
    // MARK: - Fetch
    // Income Records
    func getIncomeRecords(for uid: String, completion: @escaping (Bool, String) -> Void) async -> [Income] {
        let currentMonth = getCurrentMonth()
        let docRef = db.collection("incomes")
            .whereField("userId", isEqualTo: uid)
            .whereField("date", isGreaterThanOrEqualTo: currentMonth.start)
            .whereField("date", isLessThan: currentMonth.end)
        var details: [Income] = []
        do {
            let snapshot = try await docRef.getDocuments()
            for document in snapshot.documents {
                let amount = document["amount"]
                let note = document["note"]
                let userId = document["userId"]
                
                var created: Date? = nil
                var date: Date? = nil
                if let ts = document["createdAt"] as? Timestamp {
                    created = ts.dateValue()
                }
                if let ts = document["date"] as? Timestamp {
                    date = ts.dateValue()
                }
                completion(true, "Got the data from firestore")
                details.append(
                    Income(
                        uid: userId as? String ?? "",
                        amount: amount as? Double ?? 0,
                        date: date,
                        createdAt: created,
                        note: note as? String ?? ""
                    )
                )
                Log.success("Income Records: \(details)")
            }
            return details
        } catch {
            completion(false, "Failed to fetch income records")
            Log.error("Failed to fetch income records")
            return details
        }
    }
    
    // Expenses Records
    func getExpensesRecords(for uid: String, completion: @escaping(Bool, String) -> Void) async -> [Expenses] {
        let currentMonth = getCurrentMonth()
        let docRef = db.collection("expenses")
            .whereField("userId", isEqualTo: uid)
            .whereField("date", isGreaterThanOrEqualTo: currentMonth.start)
            .whereField("date", isLessThan: currentMonth.end)
        var details: [Expenses] = []
        do {
            let snapshot = try await docRef.getDocuments()
            for document in snapshot.documents {
                let amount = document["amount"]
                let categoryIcon = document["categoryIcon"]
                let categoryId = document["categoryId"]
                let categoryName = document["categoryName"]
                let id = document["id"]
                let paymentType = document["paymentType"]
                let userId = document["userId"]
                var created: Date? = nil
                var date: Date? = nil
                var updated: Date? = nil
                if let ts = document["createdAt"] as? Timestamp {
                    created = ts.dateValue()
                }
                if let ts = document["date"] as? Timestamp {
                    date = ts.dateValue()
                }
                if let ts = document["updatedAt"] as? Timestamp {
                    updated = ts.dateValue()
                }
                details.append(
                    Expenses(
                        amount: amount as? Double ?? 0,
                        categoryIcon: categoryIcon as? String ?? "",
                        categoryId: categoryId as? String ?? "",
                        categoryName: categoryName as? String ?? "",
                        createdAt: created,
                        date: date,
                        id: id as? String ?? "",
                        paymentType: paymentType as? String ?? "",
                        updatedAt: updated,
                        userId: userId as? String ?? "")
                    )
                Log.success("Expense Records: \(details)")
                completion(true, "Successfully fetched expenses records")
            }
            return details
        } catch {
            completion(false, "failed to fetch expenses records")
            Log.error("Failed to fetch expenses records")
            return details
        }
    }
    
}
