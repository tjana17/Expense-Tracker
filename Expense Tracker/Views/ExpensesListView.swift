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
    var body: some View {
        VStack {
            VStack(spacing: 15) {
                let currencySymbol = Currency.symbol(from: authVM.userProfile?.currency ?? "USD - US Dollar")
                if let expenses = expenseVM.allExpenseRecords, !expenses.isEmpty {
                    ScrollView {
                        ForEach(Array(expenses).reversed()) { expense in
                            transactionRow(
                                icon: expense.categoryIcon.isEmpty ? "circle" : expense.categoryIcon,
                                title: expense.categoryName,
                                date: formattedDate(expense.date),
                                amount: "\(formatCurrency(expense.amount, symbol: currencySymbol))",
                                color: colorForIcon(expense.categoryIcon),
                                isPositive: false
                            )
                        }
                    }
                }
            }
        }
        .navigationTitle("Expenses")
        .onAppear() {
            Task {
                await expenseVM.getAllExpenseRecords()
            }
        }
    }
    
    private func transactionRow(
        icon: String, title: String, date: String,
        amount: String, color: Color, isPositive: Bool
    ) -> some View {

        HStack {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)
                Image(systemName: icon)
                    .foregroundColor(color)
            }

            VStack(alignment: .leading) {
                Text(title)
                    .foregroundColor(.white)
                    .font(.headline)

                Text(date)
                    .foregroundColor(.white.opacity(0.6))
                    .font(.caption)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(amount)
                    .foregroundColor(.white)
                Text("Cash")
                    .foregroundColor(.white.opacity(0.5))
                    .font(.caption)
            }
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    ExpensesListView()
}
