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

private struct IncomeRowView: View {
    let amountText: String
    let note: String
    let dateText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Amount in title font
            Text(amountText)
                .font(.title3.bold())
                .foregroundColor(.white)

            HStack(alignment: .firstTextBaseline) {
                // Note on the left (below amount)
                Text(note.isEmpty ? "—" : note)
                    .foregroundColor(.white.opacity(0.7))
                    .font(.subheadline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Spacer()

                // Date on the right
                Text(dateText)
                    .foregroundColor(.white.opacity(0.6))
                    .font(.caption)
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    NavigationStack {
        IncomesListView()
            .environmentObject(AuthViewModel())
            .preferredColorScheme(.dark)
    }
}
