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
    
    
    // MARK: - Fetch
    // Income Records
    func getIncomeRecords(for uid: String, completion: @escaping (Bool, String) -> Void) async {
        let docRef = db.collection("incomes").whereField("userId", isEqualTo: uid)
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
                debugPrint("Income Record: \(details)")
            }
        } catch {
            completion(false, "")
        }
    }
    
    // Expenses Records
    func getExpensesRecords(for uid: String, completion: @escaping(Bool, String) -> Void) async {
        let docRef = db.collection("expenses").whereField("userId", isEqualTo: uid)
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
                debugPrint("Expenses Record: \(details)")
                completion(true, "Successfully fetched expenses records")
            }
        } catch {
            completion(false, "failed to fetch expenses records")
        }
    }
    
}
