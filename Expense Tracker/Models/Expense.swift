//
//  Expense.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 30/11/25.
//

import Foundation
import SwiftUI

struct Expense: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
    let amount: Double
    let category: ExpenseCategory
    let isPositive: Bool
}

enum ExpenseCategory: String, CaseIterable {
    case food, medicine, entertainment, transport, projects
    var color: Color {
        switch self {
        case .food: return .orange
        case .medicine: return .teal
        case .entertainment: return .purple
        case .transport: return .blue
        case .projects: return .pink
        }
    }
}

struct TransactionItem: Identifiable {
    let id = UUID()
    let title: String
    let amount: Double
    let category: ExpenseCategory
    let categoryIcon: String
    let isPositive: Bool
    let date: Date

    var amountString: String { "\(isPositive ? "+" : "-") $\(String(format: "%.2f", abs(amount)))" }

    var dateString: String {
        let f = DateFormatter()
        f.dateFormat = "MMM dd, hh:mm a"
        return f.string(from: date)
    }
}

