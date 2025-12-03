//
//  CategorySpending.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 30/11/25.
//

import Foundation
import SwiftUI

struct CategorySpending: Identifiable {
    let id = UUID()
    let category: ExpenseCategory
    let amount: Double
}

struct WeeklySpending: Identifiable {
    let id = UUID()
    let day: String
    let amount: Double
}

struct CategoryData: Identifiable {
    let id = UUID()
    let category: ExpenseCategory
    let amount: Double
    let color: Color
}
