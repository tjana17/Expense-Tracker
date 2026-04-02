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
    
    // Selection/editing state
    @State private var editingExpense: Expenses? = nil
    @State private var isPresentingEdit: Bool = false
    @State private var isDeleting: Bool = false
    @State private var deleteError: String? = nil
    @State private var pendingDelete: Expenses? = nil   // For confirmation
    @State private var showDeleteAlert: Bool = false    // Alert for delete
    
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
        let groups = Dictionary(grouping: expenses) { exp in
            monthKey(for: exp.date)
        }
        var result: [(month: Date, items: [Expenses], total: Double)] = []
        for (key, items) in groups {
            if let month = key {
                let total = items.reduce(0.0) { $0 + $1.amount }
                result.append((month: month, items: items, total: total))
            }
        }
        result.sort { $0.month > $1.month }
        return result
    }
    
    // MARK: - Actions
    private func requestEdit(_ expense: Expenses) {
        editingExpense = expense
        isPresentingEdit = true
    }
    
    private func confirmDelete() {
        guard let expense = pendingDelete else { return }
        Task {
            isDeleting = true
            defer { isDeleting = false; pendingDelete = nil }
            do {
                try await expenseVM.deleteExpense(expense)
            } catch {
                deleteError = error.localizedDescription
            }
        }
    }
    
    var body: some View {
        let currencySymbol = Currency.symbol(from: authVM.userProfile?.currency ?? "USD - US Dollar")
        
        List {
            if let expenses = expenseVM.allExpenseRecords, !expenses.isEmpty {
                // Month sections
                let monthGroups = groupedByMonth(expenses)
                ForEach(monthGroups, id: \.month) { group in
                    Section {
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
                            .listRowBackground(Color.white.opacity(0.06))
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    pendingDelete = expense
                                    showDeleteAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button {
                                    requestEdit(expense)
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                        }
                    } header: {
                        HStack {
                            Text(monthTitle(from: group.month))
                                .foregroundColor(.white)
                                .font(.system(size: 18).bold())
                            Spacer()
                            Text("\(formatCurrency(group.total, symbol: currencySymbol))")
                                .foregroundColor(.white)
                                .font(.system(size: 18).bold())
                        }
                        .padding(.vertical, 6)
                        .textCase(nil)
                    }
                }
                
                // Optional: items with nil date as a final section
                let undated = expenses.filter { $0.date == nil }
                if !undated.isEmpty {
                    let total = undated.reduce(0.0) { $0 + $1.amount }
                    Section {
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
                            .listRowBackground(Color.white.opacity(0.06))
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    pendingDelete = expense
                                    showDeleteAlert = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button {
                                    requestEdit(expense)
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                        }
                    } header: {
                        HStack {
                            Text("No Date")
                                .foregroundColor(.white)
                                .font(.system(size: 18).bold())
                            Spacer()
                            Text("\(formatCurrency(total, symbol: currencySymbol))")
                                .foregroundColor(.white)
                                .font(.system(size: 18).bold())
                        }
                        .padding(.vertical, 6)
                        .textCase(nil)
                    }
                }
            } else {
                // Empty state
                Text("No expenses found.")
                    .foregroundColor(.white.opacity(0.6))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)                         // Use plain for cleaner look
        .listRowSeparator(.hidden)                 // Hide separators globally
        .listSectionSeparator(.hidden)             // Hide section separators (iOS 16+)
        .scrollContentBackground(.hidden)          // Hide default list background
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Expenses")
        .onAppear {
            Task { await expenseVM.getAllExpenseRecords() }
        }
        // Edit sheet
        .sheet(isPresented: $isPresentingEdit) {
            if let expense = editingExpense {
                ExpenseEditSheet(expense: expense) { updated in
                    Task {
                        do {
                            try await expenseVM.updateExpense(updated)
                        } catch {
                            deleteError = error.localizedDescription
                        }
                        isPresentingEdit = false
                    }
                } onCancel: {
                    isPresentingEdit = false
                }
                .presentationDetents([.medium, .large])
            }
        }
        // Delete alert (replaces confirmationDialog)
        .alert(
            "Delete this expense?",
            isPresented: $showDeleteAlert,
            presenting: pendingDelete
        ) { _ in
            Button("Delete", role: .destructive) {
                confirmDelete()
            }
            Button("Cancel", role: .cancel) {
                pendingDelete = nil
            }
        } message: { exp in
            Text("This will permanently delete “\(exp.categoryName)” for \(formatCurrency(exp.amount, symbol: Currency.symbol(from: authVM.userProfile?.currency ?? "USD - US Dollar"))) on \(formattedDate(exp.date)).")
        }
        // Error alert
        .alert("Operation Failed", isPresented: .constant(deleteError != nil), actions: {
            Button("OK", role: .cancel) { deleteError = nil }
        }, message: {
            Text(deleteError ?? "")
        })
    }
}

private struct ExpenseEditSheet: View {
    let expense: Expenses
    var onSave: (Expenses) -> Void
    var onCancel: () -> Void
    
    // Local editable copies (adjust fields you actually allow editing)
    @State private var amount: String = ""
    @State private var date: Date = .now
    @State private var paymentType: String = ""
    
    init(expense: Expenses, onSave: @escaping (Expenses) -> Void, onCancel: @escaping () -> Void) {
        self.expense = expense
        self.onSave = onSave
        self.onCancel = onCancel
        _amount = State(initialValue: String(expense.amount))
        _date = State(initialValue: expense.date ?? Date())
        _paymentType = State(initialValue: expense.paymentType)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Amount") {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                        .foregroundColor(.primary)
                }
                Section("Date") {
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                        .foregroundColor(.primary)
                }
                Section("Payment Type") {
                    TextField("Payment Type", text: $paymentType)
                        .foregroundColor(.primary)
                }
            }
            .scrollContentBackground(.hidden)   // hide default Form background
            .background(Color.black)            // visible background in dark theme
            .navigationTitle("Edit Expense")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let updated = Expenses(
                            amount: Double(amount) ?? expense.amount,
                            categoryIcon: expense.categoryIcon,
                            categoryId: expense.categoryId,
                            categoryName: expense.categoryName,
                            createdAt: expense.createdAt,
                            date: date,
                            id: expense.id,
                            note: expense.note,
                            paymentType: paymentType,
                            updatedAt: Date(),
                            userId: expense.userId
                        )
                        onSave(updated)
                    }
                }
            }
        }
        .tint(.white) // keep controls visible on dark bg
    }
}

#Preview {
    ExpensesListView()
        .environmentObject(AuthViewModel())
}
