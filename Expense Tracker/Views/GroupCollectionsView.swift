//
//  GroupCollectionsView.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 24/01/26.
//

import SwiftUI
import FirebaseAuth

struct GroupCollectionsView: View {
    // Access current user
    @EnvironmentObject private var authVM: AuthViewModel
    // ViewModel for categories
    @StateObject private var categoriesVM = CategoriesViewModel()
    // Layout: 3 columns for a 3x3 grid
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    @StateObject private var expenseVM = ExpenseHomeViewModel()
    @State private var showExpenseList: Bool = false
    @State private var showIncomeList: Bool = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 25) {
                CategoriesView()
                
                // Income preview section
                VStack {
                    SectionHeaderView(title: "Income") {
                        showIncomeList = true
                    }
                    incomePreviewSection
                }
                
                VStack {
                    SectionHeaderView(title: "Expenses") {
                        showExpenseList = true
                    }
                    expensesSection
                }
                Spacer(minLength: 100)
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            guard let uid = authVM.user?.uid else { return }
            Task {
                do {
                    try await categoriesVM.fetchCategoriesForUser(userId: uid)
                    // Load incomes for the preview/list
                    await expenseVM.getAllIncomeRecords()
                    // Current-month data for stats
                    await expenseVM.getCurrentMonthRecords()
                } catch {
                    print("Failed to fetch categories: \(error.localizedDescription)")
                }
            }
        }
        // Navigation destinations
        .navigationDestination(isPresented: $showExpenseList) {
            ExpensesListView()
        }
        .navigationDestination(isPresented: $showIncomeList) {
            IncomesListView()
        }
    }
    
    fileprivate func CategoriesView() -> some View {
        return VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: "Categories") {
                Log.info("Categories")
            }
            
            if categoriesVM.categories.isEmpty {
                // Empty state
                EmptyCategoriesView()
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(categoriesVM.categories.prefix(9)) { category in
                        CategoryCard(category: category)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top, 16)
    }
    
    fileprivate func EmptyCategoriesView() -> some View {
        return VStack(spacing: 12) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 36))
                .foregroundColor(.white.opacity(0.6))
            Text("No categories yet")
                .foregroundColor(.white.opacity(0.8))
            Text("Add some categories to get started.")
                .foregroundColor(.white.opacity(0.6))
                .font(.footnote)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

extension GroupCollectionsView {
    // MARK: - Income Preview (last 3, amount + note + date right-aligned)
    private var incomePreviewSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            let currencySymbol = Currency.symbol(from: authVM.userProfile?.currency ?? "USD - US Dollar")
            if let incomes = expenseVM.allIncomeRecords, !incomes.isEmpty {
                // Sort newest first and take last three by date
                let sorted = incomes.sorted {
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
                let lastThree = Array(sorted.prefix(3))
                
                VStack(spacing: 15) {
                    // Use enumerated index as unique identity
                    ForEach(Array(lastThree.enumerated()), id: \.offset) { _, income in
                        IncomeRowView(
                            amountText: formatCurrency(income.amount, symbol: currencySymbol),
                            note: income.note,
                            dateText: formattedDate(income.date)
                        )
                    }
                }
            } else {
                Text("No income records found.")
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
    
    // Existing Expenses section unchanged
    private var expensesSection: some View {
        VStack(alignment: .leading, spacing: 15) {

            VStack(spacing: 15) {
                let currencySymbol = Currency.symbol(from: authVM.userProfile?.currency ?? "USD - US Dollar")
                if let expenses = expenseVM.currentExpenseRecords, !expenses.isEmpty {
                    ForEach(Array(expenses.suffix(3)).reversed()) { expense in
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
}

#Preview {
    GroupCollectionsView()
        .environmentObject(AuthViewModel())
}
