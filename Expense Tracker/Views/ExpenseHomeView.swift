//
//  ExpenseHomeView.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 30/11/25.
//

import SwiftUI
import FirebaseAuth

struct ExpenseHomeView: View {

    @State private var selectedTab: Int = 0
    // Use shared AuthViewModel from environment
    @EnvironmentObject private var authVM: AuthViewModel
    
    // Toast state
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var toastStyle: ToastStyle = .success
    @StateObject private var expenseVM = ExpenseHomeViewModel()
    @State private var showExpenseList: Bool = false


    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                homeView
                    .tag(0)
                
                ExpenseChartView()
                    .tag(1)
                
                AddExpenseView()
                    .tag(10)
                
                GroupCollectionsView()
                    .tag(2)
                
                ProfileView()
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never)) // Hides default tab bar
            
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        // Reusable toast overlay
        .toast(isPresented: $showToast, message: toastMessage, style: toastStyle)
        // Move navigationDestination here (outside lazy containers)
        .navigationDestination(isPresented: $showExpenseList) {
            ExpensesListView()
        }
    }
    
    private var homeView: some View {
        VStack(spacing: 0) {
            // ⭐ FIXED HEADER
            headerSection
                .padding()
                .background(Color.black)
                .zIndex(1)
            
            // ⭐ Scrollable content BELOW header
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    balanceSection
                    statsCards
                    aiInsightCard
                    transactionsSection
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .background(Color.black)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            Task {
                // Current-month data for stats
                await expenseVM.getCurrentMonthRecords()
                // Previous-month data for stats
                await expenseVM.getPreviousMonthRecords()
            }
        }

    }
    

}


struct ExpenseHomeView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseHomeView()
    }
}

extension ExpenseHomeView {

    private var headerSection: some View {
        HStack {
            iconButton(system: "square.grid.2x2.fill")

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "wallet.bifold")
                    .foregroundColor(.white)
                Text("All account")
                    .foregroundColor(.white)
                Image(systemName: "chevron.down")
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.15))
            .clipShape(Capsule())

            Spacer()

            iconButton(system: "bell.fill")
        }
    }

    private func iconButton(system: String) -> some View {
        Button(action: {
            // Show success toast locally
            showToast(message: "Expense saved successfully", style: .success)
        
        }) {
            Image(systemName: system)
                .foregroundColor(.white)
                .padding(12)
                .background(Color.white.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
    
    // MARK: - Local toast helper
    private func showToast(message: String, style: ToastStyle) {
        toastMessage = message
        toastStyle = style
        withAnimation {
            showToast = true
        }
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                withAnimation {
                    showToast = false
                }
            }
        }
    }
}

extension ExpenseHomeView {

    private var balanceSection: some View {
        VStack(spacing: 5) {
            let currencySymbol = Currency.symbol(from: authVM.userProfile?.currency ?? "USD - US Dollar")
            let income = expenseVM.currentIncomeRecords?.first?.amount
            let expense = expenseVM.currentExpenseRecords?.compactMap { $0.amount }.reduce(0, +)
            let totalBalance: Double = (income ?? 0.0) - (expense ?? 0.0)
            Text("Total Balance")
                .foregroundColor(.white.opacity(0.7))
                .font(.headline)

            Text("\(formatCurrency(totalBalance, symbol: currencySymbol))")
                .font(.system(size: 42, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.top, 10)
    }
}

extension ExpenseHomeView {

    private var statsCards: some View {
        HStack(spacing: 15) {
            let currencySymbol = Currency.symbol(from: authVM.userProfile?.currency ?? "USD - US Dollar")
            
            // Current totals
            let currentIncome = expenseVM.currentIncomeRecords?.compactMap { $0.amount }.reduce(0, +) ?? 0
            let currentExpense = expenseVM.currentExpenseRecords?.compactMap { $0.amount }.reduce(0, +) ?? 0
            
            // Previous totals
            let previousIncome = expenseVM.previousIncomeRecords?.compactMap { $0.amount }.reduce(0, +) ?? 0
            let previousExpense = expenseVM.previousExpenseRecords?.compactMap { $0.amount }.reduce(0, +) ?? 0
            
            // Percentage changes (numeric, for color)
            let incomeChange = percentChange(current: currentIncome, previous: previousIncome)
            let expenseChange = percentChange(current: currentExpense, previous: previousExpense)
            
            // Colors: income up is green, down is red; expenses up is red, down is green.
            let incomeColor: Color = trendColor(change: incomeChange, positiveIsGood: true)
            let expenseColor: Color = trendColor(change: expenseChange, positiveIsGood: false)
            
            statCard(
                title: "Expense",
                amount: "\(formatCurrency(currentExpense, symbol: currencySymbol))",
                percent: safeFormattedPercent(current: currentExpense, previous: previousExpense),
                color: expenseColor
            )

            statCard(
                title: "Income",
                amount: "\(formatCurrency(currentIncome, symbol: currencySymbol))",
                percent: safeFormattedPercent(current: currentIncome, previous: previousIncome),
                color: incomeColor
            )
        }
    }

    private func statCard(title: String, amount: String, percent: String, color: Color) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .foregroundColor(.white.opacity(0.6))
            Text(amount)
                .foregroundColor(.white)
                .font(.title3.bold())

            HStack {
                Image(systemName: color == .red ? "arrow.down.right" : "arrow.up.right")
                    .foregroundColor(color)
                Text(percent + " vs last month")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.caption)
            }
        }
        .padding()
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

extension ExpenseHomeView {

    private var aiInsightCard: some View {
        let currencySymbol = Currency.symbol(from: authVM.userProfile?.currency ?? "USD - US Dollar")
        let totalIncome = expenseVM.currentIncomeRecords?.compactMap { $0.amount }.reduce(0, +) ?? 0
        let totalExpense = expenseVM.currentExpenseRecords?.compactMap { $0.amount }.reduce(0, +) ?? 0
        let net = totalIncome - totalExpense
        let savingsRate = totalIncome > 0 ? (net / totalIncome) : 0
        
        let (titleColor, message) = aiInsightText(totalIncome: totalIncome, totalExpense: totalExpense, net: net, savingsRate: savingsRate, currencySymbol: currencySymbol)

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(titleColor)
                Text("AI Insight")
                    .foregroundColor(titleColor)
                    .font(.headline)
            }

            Text(message)
                .foregroundColor(.white)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(titleColor, lineWidth: 1)
                .background(Color.white.opacity(0.05))
        )
    }
    
    // Build insight text from live Firestore data
    private func aiInsightText(totalIncome: Double, totalExpense: Double, net: Double, savingsRate: Double, currencySymbol: String) -> (Color, String) {
        // Choose a color mood
        let color: Color
        let msg: String
        
        switch savingsRate {
            case let r where r >= 0.2:
                color = .green
                msg = "Great job! You’ve saved \(formatCurrency(net, symbol: currencySymbol)) this month (\(Int(r * 100))%). Keep it up!"
            case 0.0..<0.2:
                color = .yellow
                if net >= 0 {
                    msg = "Nice! You’re in the green with \(formatCurrency(net, symbol: currencySymbol)) saved (\(Int(savingsRate * 100))%). Consider trimming dining/entertainment to boost savings."
                } else {
                    msg = "Heads up: you’re overspending by \(formatCurrency(abs(net), symbol: currencySymbol)). Review recurring costs to get back on track."
                }
            default:
                color = .red
                msg = "Alert: expenses (\(formatCurrency(totalExpense, symbol: currencySymbol))) exceed income (\(formatCurrency(totalIncome, symbol: currencySymbol))). Try pausing non-essential spending."
        }
        return (color, msg)
    }
}

extension ExpenseHomeView {

    private var transactionsSection: some View {
        VStack(alignment: .leading, spacing: 15) {

            HStack {
                Text("Expenses")
                    .font(.title3.bold())
                    .foregroundColor(.white)

                Spacer()

                Text("Show All")
                    .foregroundColor(.white.opacity(0.6))
                    .onTapGesture {
                        showExpenseList = true
                    }
            }

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
