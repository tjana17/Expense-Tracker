//
//  ExpenseHomeViewModel.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 30/11/25.
//

import SwiftUI
import Combine

@MainActor
class ExpenseHomeViewModel: ObservableObject {

    @Published var isLoading = true
    @Published var totalBalance: Double = 0
    @Published var expenses: [Expense] = []
    @Published var categorySpending: [CategorySpending] = []
    @Published var aiAlert: String = ""

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
}
