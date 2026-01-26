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
    // New: generic month range by offset (e.g., -1 for previous month)
    func getMonth(offsetBy months: Int) -> (start: Date, end: Date) {
        let date = Date()
        let calendar = Calendar.current
        let target = calendar.date(byAdding: .month, value: months, to: date) ?? date
        let year = calendar.component(.year, from: target)
        let month = calendar.component(.month, from: target)

        let components = DateComponents(year: year, month: month, day: 1)
        let start = calendar.date(from: components)!
        let end = calendar.date(byAdding: .month, value: 1, to: start)!
        Log.info("Month offset \(months) -> Year \(year), Month \(month)")
        return (start, end)
    }
    
    // MARK: - Fetch
    // Fetch All Income Records
    func getIncomeRecords(for uid: String, completion: @escaping (Bool, String) -> Void) async -> [Income] {
        let docRef = db.collection("incomes")
            .whereField("userId", isEqualTo: uid)
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
            }
            return details
        } catch {
            completion(false, "Failed to fetch income records")
            Log.error("Failed to fetch income records")
            return details
        }
    }
    
    // New: Income Records for a specific month offset
    func getIncomeRecords(for uid: String, monthOffset: Int, completion: @escaping (Bool, String) -> Void) async -> [Income] {
        let range = getMonth(offsetBy: monthOffset)
        let docRef = db.collection("incomes")
            .whereField("userId", isEqualTo: uid)
            .whereField("date", isGreaterThanOrEqualTo: range.start)
            .whereField("date", isLessThan: range.end)
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
                completion(true, "Got the data from firestore (offset \(monthOffset))")
                details.append(
                    Income(
                        uid: userId as? String ?? "",
                        amount: amount as? Double ?? 0,
                        date: date,
                        createdAt: created,
                        note: note as? String ?? ""
                    )
                )
            }
            return details
        } catch {
            completion(false, "Failed to fetch income records (offset \(monthOffset))")
            Log.error("Failed to fetch income records (offset \(monthOffset))")
            return details
        }
    }
    
    // Fetch All Expenses Records
    func getExpensesRecords(for uid: String, completion: @escaping(Bool, String) -> Void) async -> [Expenses] {
        let docRef = db.collection("expenses")
            .whereField("userId", isEqualTo: uid)
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
                completion(true, "Successfully fetched expenses records")
            }
            return details
        } catch {
            completion(false, "failed to fetch expenses records")
            Log.error("Failed to fetch expenses records")
            return details
        }
    }
    
    // New: Expenses Records for a specific month offset
    func getExpensesRecords(for uid: String, monthOffset: Int, completion: @escaping(Bool, String) -> Void) async -> [Expenses] {
        let range = getMonth(offsetBy: monthOffset)
        let docRef = db.collection("expenses")
            .whereField("userId", isEqualTo: uid)
            .whereField("date", isGreaterThanOrEqualTo: range.start)
            .whereField("date", isLessThan: range.end)
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
                completion(true, "Successfully fetched expenses records (offset \(monthOffset))")
            }
            return details
        } catch {
            completion(false, "failed to fetch expenses records (offset \(monthOffset))")
            Log.error("Failed to fetch expenses records (offset \(monthOffset))")
            return details
        }
    }
    
    // MARK: - Mutations (Expenses)
    func deleteExpense(id: String) async throws {
        try await db.collection("expenses").document(id).delete()
        Log.success("Deleted expense id: \(id)")
    }
    
    func updateExpense(_ expense: Expenses) async throws {
        let payload: [String: Any] = [
            "amount": expense.amount,
            "categoryIcon": expense.categoryIcon,
            "categoryId": expense.categoryId,
            "categoryName": expense.categoryName,
            "createdAt": expense.createdAt ?? FieldValue.serverTimestamp(),
            "date": expense.date ?? FieldValue.serverTimestamp(),
            "id": expense.id,
            "paymentType": expense.paymentType,
            "updatedAt": FieldValue.serverTimestamp(),
            "userId": expense.userId
        ]
        try await db.collection("expenses").document(expense.id).setData(payload, merge: true)
        Log.success("Updated expense id: \(expense.id)")
    }
}

