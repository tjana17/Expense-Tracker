//
//  ExpensesListView.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 23/01/26.
//

import SwiftUI

struct ExpensesListView: View {
    @StateObject private var expenseVM = ExpenseHomeViewModel()
    // Use shared AuthViewModel from environment
    @EnvironmentObject private var authVM: AuthViewModel
    
    // MARK: - Grouping helpers
    private func monthKey(for date: Date?) -> Date? {
        guard let date else { return nil }
        let cal = Calendar.current
        return cal.date(from: cal.dateComponents([.year, .month], from: date))
    }
    
    private func monthTitle(from monthDate: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "LLLL yyyy" // e.g., January 2026
        return f.string(from: monthDate)
    }
    
    private func groupedByMonth(_ expenses: [Expenses]) -> [(month: Date, items: [Expenses], total: Double)] {
        // Group by normalized month (first day of month at midnight)
        let groups = Dictionary(grouping: expenses) { exp in
            monthKey(for: exp.date)
        }
        
        // Turn into array, skip nil month keys by placing them at the end if needed
        var result: [(month: Date, items: [Expenses], total: Double)] = []
        
        for (key, items) in groups {
            if let month = key {
                let total = items.reduce(0.0) { $0 + $1.amount }
                result.append((month: month, items: items, total: total))
            }
        }
        
        // Sort descending by month (newest first)
        result.sort { $0.month > $1.month }
        return result
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 15) {
                let currencySymbol = Currency.symbol(from: authVM.userProfile?.currency ?? "USD - US Dollar")
                
                if let expenses = expenseVM.allExpenseRecords, !expenses.isEmpty {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Group by month
                            let monthGroups = groupedByMonth(expenses)
                            
                            ForEach(monthGroups, id: \.month) { group in
                                VStack(alignment: .leading, spacing: 12) {
                                    // Header: Month title on left, monthly total on right
                                    HStack {
                                        Text(monthTitle(from: group.month))
                                            .foregroundColor(.white)
                                            .font(.system(size: 18).bold())
                                        Spacer()
                                        Text("\(formatCurrency(group.total, symbol: currencySymbol))")
                                            .foregroundColor(.white)
                                            .font(.system(size: 22).bold())
                                    }
                                    .padding(.horizontal, 4)
                                    
                                    // Rows sorted by date descending within month
                                    ForEach(
                                        group.items.sorted {
                                            switch ($0.date, $1.date) {
                                            case let (d0?, d1?):
                                                return d0 > d1
                                            case (nil, _?):
                                                return false
                                            case (_?, nil):
                                                return true
                                            case (nil, nil):
                                                return false
                                            }
                                        }
                                    ) { expense in
                                        TransactionRowView(
                                            systemIconName: expense.categoryIcon.isEmpty ? "circle" : expense.categoryIcon,
                                            title: expense.categoryName,
                                            subtitle: formattedDate(expense.date),
                                            amountText: "\(formatCurrency(expense.amount, symbol: currencySymbol))",
                                            tint: colorForIcon(expense.categoryIcon),
                                            accessoryText: "Cash",
                                            isPositive: false
                                        )
                                    }
                                }
                            }
                            
                            // Optional: handle any items with nil date as a final group
                            if let expenses = expenseVM.allExpenseRecords {
                                let undated = expenses.filter { $0.date == nil }
                                if !undated.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            Text("No Date")
                                                .foregroundColor(.white)
                                                .font(.headline)
                                            Spacer()
                                            let total = undated.reduce(0.0) { $0 + $1.amount }
                                            Text("\(formatCurrency(total, symbol: currencySymbol))")
                                                .foregroundColor(.white)
                                                .font(.headline)
                                        }
                                        .padding(.horizontal, 4)
                                        
                                        ForEach(undated) { expense in
                                            TransactionRowView(
                                                systemIconName: expense.categoryIcon.isEmpty ? "circle" : expense.categoryIcon,
                                                title: expense.categoryName,
                                                subtitle: formattedDate(expense.date),
                                                amountText: "\(formatCurrency(expense.amount, symbol: currencySymbol))",
                                                tint: colorForIcon(expense.categoryIcon),
                                                accessoryText: "Cash",
                                                isPositive: false
                                            )
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Expenses")
        .onAppear() {
            Task {
                await expenseVM.getAllExpenseRecords()
            }
        }
    }
}

#Preview {
    ExpensesListView()
        .environmentObject(AuthViewModel())
}
