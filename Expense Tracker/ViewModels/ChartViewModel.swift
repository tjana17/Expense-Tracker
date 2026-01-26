//
//  ChartViewModel.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 03/12/25.
//

import SwiftUI
import Combine
import FirebaseAuth

@MainActor
class ChartViewModel: ObservableObject {

    enum Period: String, CaseIterable, Identifiable {
        case weekly = "Weekly"
        case monthly = "Monthly"
        var id: String { rawValue }
    }

    @Published var selectedPeriod: Period = .weekly

    @Published var weeklySpending: [WeeklySpending] = [
        .init(day: "Mon", amount: 0),
        .init(day: "Tue", amount: 0),
        .init(day: "Wed", amount: 0),
        .init(day: "Thu", amount: 0),
        .init(day: "Fri", amount: 0),
        .init(day: "Sat", amount: 0),
        .init(day: "Sun", amount: 0)
    ]

    // Reuse WeeklySpending as a generic (label + amount) for month days "1"..."N"
    @Published var monthlySpending: [WeeklySpending] = []

    // Category summary data (now Firestore-backed categories)
    @Published var categoryData: [CategoryData] = []

    // Center totals for donut (Income, Expenses, Savings)
    @Published var totalIncome: Double = 0
    @Published var totalExpenses: Double = 0
    @Published var totalSavings: Double = 0

    // Optional selection by Firestore category id
    @Published var selectedCategoryId: String? = nil

    // Local sample transactions are no longer used for categories; kept for compatibility if needed
    @Published var transactions: [TransactionItem] = []

    private let firestoreManager = FirestoreManager.shared

    // Public entry: load current calendar week (Mon–Sun) for the signed-in user
    func loadCurrentWeekSpending() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.weeklySpending = Self.emptyWeek()
            self.categoryData = []
            self.totalIncome = 0
            self.totalExpenses = 0
            self.totalSavings = 0
            return
        }

        let (startOfWeek, endOfWeek) = Self.currentWeekRange()

        let all = await firestoreManager.getExpensesRecords(for: uid) { _, _ in }
        let weekExpenses = all.compactMap { exp -> (date: Date, amount: Double, categoryId: String, categoryName: String, categoryIcon: String)? in
            guard let d = exp.date else { return nil }
            return (d, exp.amount, exp.categoryId, exp.categoryName, exp.categoryIcon)
        }
        .filter { $0.date >= startOfWeek && $0.date < endOfWeek }

        // Build weekday totals
        let calendar = Calendar.current
        var totalsByWeekday: [Int: Double] = [:] // 1=Sun … 7=Sat
        for item in weekExpenses {
            let wd = calendar.component(.weekday, from: item.date)
            totalsByWeekday[wd, default: 0] += item.amount
        }

        let ordered = Self.weekdayDisplayOrder().map { entry -> WeeklySpending in
            let (symbol, weekday) = entry
            let total = totalsByWeekday[weekday] ?? 0
            return WeeklySpending(day: symbol, amount: total)
        }
        self.weeklySpending = ordered

        // Refresh totals and category summary
        await loadIncomeExpenseSummary()
        await loadCategorySummary(for: weekExpenses.map { ($0.amount, $0.categoryId, $0.categoryName) })
    }

    // Public entry: load current calendar month (1…N) totals
    func loadCurrentMonthSpending() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.monthlySpending = []
            self.categoryData = []
            self.totalIncome = 0
            self.totalExpenses = 0
            self.totalSavings = 0
            return
        }

        let cal = Calendar.current
        let today = Date()
        let comps = cal.dateComponents([.year, .month], from: today)
        guard
            let year = comps.year,
            let month = comps.month,
            let startOfMonth = cal.date(from: DateComponents(year: year, month: month, day: 1)),
            let startOfNextMonth = cal.date(byAdding: .month, value: 1, to: startOfMonth)
        else {
            self.monthlySpending = []
            return
        }

        let all = await firestoreManager.getExpensesRecords(for: uid) { _, _ in }
        let monthExpenses = all.compactMap { exp -> (date: Date, amount: Double, categoryId: String, categoryName: String, categoryIcon: String)? in
            guard let d = exp.date else { return nil }
            return (d, exp.amount, exp.categoryId, exp.categoryName, exp.categoryIcon)
        }
        .filter { $0.date >= startOfMonth && $0.date < startOfNextMonth }

        // Compute number of days in month
        let range = cal.range(of: .day, in: .month, for: startOfMonth) ?? 1..<31
        let daysCount = range.count

        // Sum by day-of-month (1…N)
        var totalsByDay: [Int: Double] = [:]
        for item in monthExpenses {
            let day = cal.component(.day, from: item.date)
            totalsByDay[day, default: 0] += item.amount
        }

        // Build ordered array with labels "1"…"N"
        let result: [WeeklySpending] = (1...daysCount).map { d in
            WeeklySpending(day: "\(d)", amount: totalsByDay[d] ?? 0)
        }

        self.monthlySpending = result

        // Refresh totals and category summary
        await loadIncomeExpenseSummary()
        await loadCategorySummary(for: monthExpenses.map { ($0.amount, $0.categoryId, $0.categoryName) })
    }

    // MARK: - Donut Summary Loader (Income, Expenses, Savings)
    func loadIncomeExpenseSummary() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.totalIncome = 0
            self.totalExpenses = 0
            self.totalSavings = 0
            // keep categoryData untouched here; category summary is loaded separately
            return
        }

        // Build date range based on selectedPeriod
        let cal = Calendar.current
        let now = Date()

        let range: (start: Date, end: Date)? = {
            switch selectedPeriod {
            case .weekly:
                return Self.currentWeekRange()
            case .monthly:
                let comps = cal.dateComponents([.year, .month], from: now)
                guard
                    let year = comps.year,
                    let month = comps.month,
                    let startOfMonth = cal.date(from: DateComponents(year: year, month: month, day: 1)),
                    let startOfNextMonth = cal.date(byAdding: .month, value: 1, to: startOfMonth)
                else { return nil }
                return (startOfMonth, startOfNextMonth)
            }
        }()

        // Fetch all incomes and expenses, then filter by range client-side
        async let incomesAll = firestoreManager.getIncomeRecords(for: uid) { _, _ in }
        async let expensesAll = firestoreManager.getExpensesRecords(for: uid) { _, _ in }

        let incomes = await incomesAll
        let expenses = await expensesAll

        let filteredIncome: [Income]
        let filteredExpenses: [Expenses]

        if let r = range {
            filteredIncome = incomes.filter { inc in
                if let d = inc.date {
                    return d >= r.start && d < r.end
                }
                return false
            }
            filteredExpenses = expenses.filter { exp in
                if let d = exp.date {
                    return d >= r.start && d < r.end
                }
                return false
            }
        } else {
            filteredIncome = incomes
            filteredExpenses = expenses
        }

        let incomeTotal = filteredIncome.reduce(0.0) { $0 + $1.amount }
        let expenseTotal = filteredExpenses.reduce(0.0) { $0 + $1.amount }
        let savings = max(incomeTotal - expenseTotal, 0)

        self.totalIncome = incomeTotal
        self.totalExpenses = expenseTotal
        self.totalSavings = savings
        // Note: categoryData is managed by loadCategorySummary
    }

    // Build per-category summary for the selected period using Firestore categories
    private func loadCategorySummary(for tuples: [(amount: Double, categoryId: String, categoryName: String)]) async {
        // Group by categoryId to avoid duplicates differing only by casing
        var byCategory: [String: (name: String, total: Double)] = [:]
        for t in tuples {
            var entry = byCategory[t.categoryId] ?? (name: t.categoryName, total: 0)
            entry.total += t.amount
            byCategory[t.categoryId] = entry
        }

        // Map to CategoryData with deterministic colors
        let mapped: [CategoryData] = byCategory.map { (key, value) in
            CategoryData(
                categoryId: key,
                categoryName: value.name,
                amount: value.total,
                color: Color.colorForCategoryKey(key.isEmpty ? value.name : key)
            )
        }
        // Sort descending by amount
        self.categoryData = mapped.sorted { $0.amount > $1.amount }
    }

    // Helpers

    private func makeDonutSegments(income: Double, expenses: Double, savings: Double) -> [CategoryData] {
        // Keep the donut as a 3-segment summary; we do not display categoryName here, but we need placeholders
        return [
            CategoryData(categoryId: "savings", categoryName: "Savings", amount: savings, color: .green),
            CategoryData(categoryId: "expenses", categoryName: "Expenses", amount: expenses, color: .red),
            CategoryData(categoryId: "income", categoryName: "Income", amount: income, color: .blue)
        ]
    }

    private static func emptyWeek() -> [WeeklySpending] {
        [
            .init(day: "Mon", amount: 0),
            .init(day: "Tue", amount: 0),
            .init(day: "Wed", amount: 0),
            .init(day: "Thu", amount: 0),
            .init(day: "Fri", amount: 0),
            .init(day: "Sat", amount: 0),
            .init(day: "Sun", amount: 0)
        ]
    }

    // Returns (startOfWeek, endOfWeek) where week starts Monday
    private static func currentWeekRange() -> (Date, Date) {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let weekday = cal.component(.weekday, from: today)

        let offsetFromMonday: Int = {
            if weekday == 1 { // Sunday
                return 6
            } else {
                return weekday - 2
            }
        }()

        let startOfWeek = cal.date(byAdding: .day, value: -offsetFromMonday, to: today) ?? today
        let endOfWeek = cal.date(byAdding: .day, value: 7 - offsetFromMonday, to: today) ?? today.addingTimeInterval(7 * 86_400)

        return (startOfWeek, endOfWeek)
    }

    // Fixed display order Mon…Sun mapped to Calendar.weekday numbers (Sun=1 … Sat=7)
    private static func weekdayDisplayOrder() -> [(symbol: String, weekday: Int)] {
        [
            ("Mon", 2),
            ("Tue", 3),
            ("Wed", 4),
            ("Thu", 5),
            ("Fri", 6),
            ("Sat", 7),
            ("Sun", 1)
        ]
    }
}

