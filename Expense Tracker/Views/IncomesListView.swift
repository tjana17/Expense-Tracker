//
//  IncomesListView.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 24/01/26.
//

import SwiftUI

struct IncomesListView: View {
    @StateObject private var expenseVM = ExpenseHomeViewModel()
    @EnvironmentObject private var authVM: AuthViewModel

    private func sortedIncomes(_ incomes: [Income]) -> [Income] {
        incomes.sorted {
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
    }

    var body: some View {
        let currencySymbol = Currency.symbol(from: authVM.userProfile?.currency ?? "USD - US Dollar")

        ScrollView {
            LazyVStack(spacing: 14) {
                if let incomes = expenseVM.allIncomeRecords, !incomes.isEmpty {
                    // Use enumerated index as unique identity
                    ForEach(Array(sortedIncomes(incomes).enumerated()), id: \.offset) { _, income in
                        IncomeRowView(
                            amountText: formatCurrency(income.amount, symbol: currencySymbol),
                            note: income.note,
                            dateText: formattedDate(income.date)
                        )
                    }
                } else {
                    Text("No income records found.")
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.top, 40)
                }
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Income")
        .onAppear {
            Task { await expenseVM.getAllIncomeRecords() }
        }
    }
}

#Preview {
    NavigationStack {
        IncomesListView()
            .environmentObject(AuthViewModel())
            .preferredColorScheme(.dark)
    }
}
