//
//  ExpenseHomeViewModel.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 30/11/25.
//

import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
class ExpenseHomeViewModel: ObservableObject {

    @Published var isLoading = true
    @Published var totalBalance: Double = 0
    @Published var expenses: [Expense] = []
    @Published var categorySpending: [CategorySpending] = []
    @Published var aiAlert: String = ""
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    @Published var user: User? = nil
    @Published var lastErrorMessage: String? = nil
    // Published income loaded from Firestore
    @Published var incomeRecords: Income? = nil

    init() {
        Task { await loadDashboard() }
        self.user = Auth.auth().currentUser

        // Optionally auto-fetch profile if already signed in
        if let uid = user?.uid {
            getIncomeRecords(for: uid)
        }
    }

    func loadDashboard() async {
        isLoading = true

        try? await Task.sleep(nanoseconds: 1_200_000_000) // simulate API delay

        // Example API response
        totalBalance = 500_489
        
        expenses = [
            Expense(title: "Dinner", date: .now, amount: -89.69, category: .food, isPositive: false),
            Expense(title: "Design Project", date: .now - 86000, amount: 1500, category: .projects, isPositive: true),
            Expense(title: "Medicine", date: .now, amount: -369.54, category: .medicine, isPositive: false)
        ]

        categorySpending = [
            .init(category: .food, amount: 850),
            .init(category: .medicine, amount: 430),
            .init(category: .transport, amount: 250),
            .init(category: .entertainment, amount: 320)
        ]

        generateAIAlert()

        isLoading = false
    }

    // Mock AI insight
    func generateAIAlert() {
        let food = categorySpending.first(where: { $0.category == .food })?.amount ?? 0

        if food > 700 {
            aiAlert = "⚠️ You’re nearing your monthly dining-out budget!"
        } else {
            aiAlert = "🎉 Great job! Your spending is well-balanced this month."
        }
    }
    
    // MARK: - Fetch firestore
    // Income Records
    // Private: set up a snapshot listener for users/{uid}
    func getIncomeRecords(for uid: String) {
        // Remove old listener to avoid duplicates
        listener?.remove()
        listener = db.collection("incomes").document(uid).addSnapshotListener { snapshot, error in
            if let error = error {
                self.lastErrorMessage = error.localizedDescription
                print("Fetch Income Error: \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot, let data = snapshot.data() else {
                self.incomeRecords = nil
                return
            }
            if let income = Income(uid: uid, dict: data) {
                self.incomeRecords = income
                debugPrint("income records: \(String(describing: self.incomeRecords))")
            } else {
                self.lastErrorMessage = "Failed to parse Income Records"
                print("Failed to parse income for uid: \(uid)")
            }
        }
    }
}


struct Income: Identifiable, Codable {
    var id: String { uid }
    let uid: String
    let amount: Double
    let date: Date?
    let createdAt: Date?
    let note: String
    
    // Manual init from Firestore dictionary
    init?(uid: String, dict: [String: Any]) {
        guard
            let amount = dict["amount"] as? Double,
            let note = dict["note"] as? String
        else { return nil }
        
        var created: Date? = nil
        var date: Date? = nil
        if let ts = dict["createdAt"] as? Timestamp {
            created = ts.dateValue()
        }
        if let ts = dict["updatedAt"] as? Timestamp {
            date = ts.dateValue()
        }
        
        self.uid = uid
        self.amount = amount
        self.note = note
        self.date = date
        self.createdAt = created
    }
}
