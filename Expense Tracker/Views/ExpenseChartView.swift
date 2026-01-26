//
//  ExpenseChartView.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 03/12/25.
//

import SwiftUI
import Charts
import AVFAudio

struct ExpenseChartView: View {

    @StateObject private var vm = ChartViewModel()
    @State private var selectedTab: Int = 0

    // Selection for tooltip
    @State private var selectedPoint: WeeklySpending? = nil
    @EnvironmentObject private var authVM: AuthViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {

                // MARK: HOW YOU SPEND
                sectionHeader(title: "How You Spend")

                spendingBarChart
                    .padding(.top, -8)

                // MARK: CATEGORIES DONUT
                sectionHeader(title: "Categories")

                CategoryDonutGlowChart(
                    data: [
                        // Build 3 segments on the fly from current totals
                        CategoryData(categoryId: "income", categoryName: "Income", amount: vm.totalIncome, color: .blue),
                        CategoryData(categoryId: "expenses", categoryName: "Expenses", amount: vm.totalExpenses, color: .red),
                        CategoryData(categoryId: "savings", categoryName: "Savings", amount: vm.totalSavings, color: .green)
                    ],
                    title: vm.selectedPeriod.rawValue,
                    income: vm.totalIncome,
                    expenses: vm.totalExpenses,
                    savings: vm.totalSavings,
                    currencySymbol: Currency.symbol(from: authVM.userProfile?.currency ?? "USD - US Dollar")
                )
                .frame(height: 300)

                // MARK: CATEGORY SUMMARY
                HStack {
                    Text("Category Summary")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.top, 10)

                VStack(spacing: 12) {
                    let currencySymbol = Currency.symbol(from: authVM.userProfile?.currency ?? "USD - US Dollar")
                    let total = vm.categoryData.reduce(0.0) { $0 + max($1.amount, 0) }
                    ForEach(vm.categoryData) { item in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(item.color)
                                .frame(width: 10, height: 10)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.categoryName)
                                    .foregroundColor(.white)
                                    .font(.headline)
                                Text(percentageText(value: item.amount, total: total))
                                    .foregroundColor(.white.opacity(0.6))
                                    .font(.caption)
                            }

                            Spacer()

                            Text(formatCurrency(max(item.amount, 0), symbol: currencySymbol))
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        .padding()
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            vm.selectedCategoryId = item.categoryId
                        }
                    }
                }

                Spacer(minLength: 80)
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            Task {
                switch vm.selectedPeriod {
                case .weekly:
                    await vm.loadCurrentWeekSpending()
                case .monthly:
                    await vm.loadCurrentMonthSpending()
                }
                await vm.loadIncomeExpenseSummary()
            }
        }
        .onChange(of: vm.selectedPeriod) { newValue in
            selectedPoint = nil
            Task {
                switch newValue {
                case .weekly:
                    await vm.loadCurrentWeekSpending()
                case .monthly:
                    await vm.loadCurrentMonthSpending()
                }
                await vm.loadIncomeExpenseSummary()
            }
        }
    }

    // MARK: - Section Header
    private func sectionHeader(title: String) -> some View {
        HStack {
            Text(title)
                .font(.title.bold())
                .foregroundColor(.white)
            Spacer()

            Menu {
                Picker("Period", selection: $vm.selectedPeriod) {
                    ForEach(ChartViewModel.Period.allCases) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(vm.selectedPeriod.rawValue)
                        .foregroundColor(.white)
                    Image(systemName: "chevron.down")
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.12))
                .clipShape(Capsule())
            }
        }
    }

    // MARK: - Bar Chart
    private var spendingBarChart: some View {
        // Choose dataset based on period
        let data: [WeeklySpending] = vm.selectedPeriod == .weekly ? vm.weeklySpending : vm.monthlySpending

        return Chart {
            ForEach(data) { item in
                BarMark(
                    x: .value(vm.selectedPeriod == .weekly ? "Day" : "Date", item.day),
                    y: .value("Amount", item.amount)
                )
                .foregroundStyle(Color.blue.opacity(0.7))
                .cornerRadius(8)
                // Enable hit testing and selection
                .opacity(selectedPoint?.id == item.id ? 1.0 : 0.9)
                .annotation(position: .overlay, alignment: .top) {
                    if selectedPoint?.id == item.id {
                        tooltipView(title: item.day, amount: item.amount)
                            .offset(y: -8)
                    }
                }
                // Tap target overlay for this bar
                .annotation(position: .overlay) {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedPoint = item
                        }
                        .accessibilityLabel("Bar")
                        .accessibilityAddTraits(.isButton)
                }
            }
        }
        .frame(height: 230)
        .padding()
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            if vm.selectedPeriod == .weekly {
                AxisMarks(values: data.map { $0.day })
            } else {
                let labels = sparseMonthlyTicks(from: data)
                AxisMarks(values: labels) { value in
                    if let str = value.as(String.self) {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(str)
                    }
                }
            }
        }
        .onTapGesture {
            // Tap outside bars clears selection
            selectedPoint = nil
        }
    }

    // Tooltip content
    private func tooltipView(title: String, amount: Double) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
            Text(formatCurrency(amount, symbol: Currency.symbol(from: "USD - US Dollar")))
                .font(.caption.bold())
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // Build sparse monthly ticks from data labels (which are "1"..."N")
    private func sparseMonthlyTicks(from data: [WeeklySpending]) -> [String] {
        let ints = data.compactMap { Int($0.day) }
        guard !ints.isEmpty else { return [] }

        // Include 1, then multiples of 5, limited to existing days in data
        let set = Set(ints)
        let maxDay = ints.max() ?? 30
        var ticks: [Int] = []
        if set.contains(1) { ticks.append(1) }
        for d in stride(from: 5, through: maxDay, by: 5) where set.contains(d) {
            ticks.append(d)
        }
        return ticks.map { String($0) }
    }

    // Percentage helper
    private func percentageText(value: Double, total: Double) -> String {
        guard total > 0 else { return "0%" }
        let pct = max(value, 0) / total * 100
        return "\(Int(round(pct)))%"
    }
}



#Preview {
    ExpenseChartView()
        .environmentObject(AuthViewModel())
}

