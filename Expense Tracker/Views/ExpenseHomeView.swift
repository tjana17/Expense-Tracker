//
//  ExpenseHomeView.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 30/11/25.
//

import SwiftUI

struct ExpenseHomeView: View {

    @State private var selectedTab: Int = 0
    // Use shared AuthViewModel from environment
    @EnvironmentObject private var authVM: AuthViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                homeView
                    .tag(0)
                
                ExpenseChartView()
                    .tag(1)
                
                AddExpenseView()
                    .tag(10)
                
                ExpenseChartView()
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
            authVM.signOut()
        }) {
            Image(systemName: system)
                .foregroundColor(.white)
                .padding(12)
                .background(Color.white.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
}

extension ExpenseHomeView {

    private var balanceSection: some View {
        VStack(spacing: 5) {
            Text("Total Balance")
                .foregroundColor(.white.opacity(0.7))
                .font(.headline)

            Text("$500,489")
                .font(.system(size: 42, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.top, 10)
    }
}

extension ExpenseHomeView {

    private var statsCards: some View {
        HStack(spacing: 15) {

            statCard(
                title: "Expense",
                amount: "$24,589",
                percent: "13.39%",
                color: .red
            )

            statCard(
                title: "Income",
                amount: "$40,432",
                percent: "5.22%",
                color: .green
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
                Text(percent + " in this month")
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
        VStack(alignment: .leading, spacing: 8) {

            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
                Text("AI Insight")
                    .foregroundColor(.purple)
                    .font(.headline)
            }

            Text("Great job Jana! You’ve saved 20% more than last month.")
                .foregroundColor(.white)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.purple, lineWidth: 1)
                .background(Color.white.opacity(0.05))
        )
    }
}

extension ExpenseHomeView {

    private var transactionsSection: some View {
        VStack(alignment: .leading, spacing: 15) {

            HStack {
                Text("Transactions")
                    .font(.title3.bold())
                    .foregroundColor(.white)

                Spacer()

                Text("Show All")
                    .foregroundColor(.white.opacity(0.6))
            }

            VStack(spacing: 15) {
                transactionRow(
                    icon: "fork.knife",
                    title: "Dinner",
                    date: "Today, 12:30 AM",
                    amount: "- $89.69",
                    color: .orange,
                    isPositive: false
                )

                transactionRow(
                    icon: "shippingbox.fill",
                    title: "Design Project",
                    date: "Yesterday, 08:10 AM",
                    amount: "+ $1500.00",
                    color: .pink,
                    isPositive: true
                )

                transactionRow(
                    icon: "cross.case.fill",
                    title: "Medicine",
                    date: "Today, 12:30 AM",
                    amount: "- $369.54",
                    color: .teal,
                    isPositive: false
                )
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
                    .foregroundColor(isPositive ? .green : .red)
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
