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

    @Published var categoryData: [CategoryData] = [
        .init(category: .food, amount: 7500, color: .orange),
        .init(category: .transport, amount: 1200, color: .blue),
        .init(category: .projects, amount: 1600, color: .pink),
        .init(category: .entertainment, amount: 1800, color: .purple)
    ]

    @Published var selectedCategory: ExpenseCategory = .food

    @Published var transactions: [TransactionItem] = [
        .init(title: "Dinner", amount: -89.69, category: .food, categoryIcon: "", isPositive: false, date: .now),
        .init(title: "Fast Food", amount: 120.53, category: .food, categoryIcon: "", isPositive: true, date: .now.addingTimeInterval(-86400))
    ]

    private let firestoreManager = FirestoreManager.shared

    // Public entry: load current calendar week (Mon–Sun) for the signed-in user
    func loadCurrentWeekSpending() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.weeklySpending = Self.emptyWeek()
            return
        }

        let (startOfWeek, endOfWeek) = Self.currentWeekRange()

        let all = await firestoreManager.getExpensesRecords(for: uid) { _, _ in }
        let weekExpenses = all.compactMap { exp -> (date: Date, amount: Double)? in
            guard let d = exp.date else { return nil }
            return (d, exp.amount)
        }
        .filter { $0.date >= startOfWeek && $0.date < endOfWeek }

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
    }

    // Public entry: load current calendar month (1…N) totals
    func loadCurrentMonthSpending() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.monthlySpending = []
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

        // Option 1: reuse existing "all expenses, then filter" like weekly
        let all = await firestoreManager.getExpensesRecords(for: uid) { _, _ in }
        let monthExpenses = all.compactMap { exp -> (date: Date, amount: Double)? in
            guard let d = exp.date else { return nil }
            return (d, exp.amount)
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
    }

    // Helpers

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

    // Returns (startOfWeek, endOfWeek) where week starts Monday, using the user’s current calendar/locale
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
