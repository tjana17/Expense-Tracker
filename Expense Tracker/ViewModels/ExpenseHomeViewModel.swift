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
    private let firestoreManager = FirestoreManager.shared
    // Published income loaded from Firestore
    @Published var currentIncomeRecords: [Income]? = nil
    @Published var currentExpenseRecords: [Expenses]? = nil
    @Published var allExpenseRecords: [Expenses]? = nil
    
    // New: previous month data
    @Published var previousIncomeRecords: [Income]? = nil
    @Published var previousExpenseRecords: [Expenses]? = nil
    
    let user = Auth.auth().currentUser

    init() {
        Task { await loadDashboard() }
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
    
    // MARK: - Fetch Firestore (current month)
    func getCurrentMonthRecords() async {
        if let uid = user?.uid {
            self.currentIncomeRecords = await firestoreManager.getIncomeRecords(for: uid, monthOffset: 0) { _, _ in }
            self.currentExpenseRecords = await firestoreManager.getExpensesRecords(for: uid, monthOffset: 0) { _, _ in }
        }
    }
    
    // MARK: - Fetch Firestore (previous month)
    func getPreviousMonthRecords() async {
        if let uid = user?.uid {
            self.previousIncomeRecords = await firestoreManager.getIncomeRecords(for: uid, monthOffset: -1) { _, _ in }
            self.previousExpenseRecords = await firestoreManager.getExpensesRecords(for: uid, monthOffset: -1) { _, _ in }
        }
    }
    
    func getAllExpenseRecords() async  {
        if let uid = user?.uid {
            self.allExpenseRecords = await firestoreManager.getExpensesRecords(for: uid) { _, _ in }
        }
    }

}

