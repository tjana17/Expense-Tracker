//
//  ExpenseChartView.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 03/12/25.
//

import SwiftUI
import Charts

struct ExpenseChartView: View {

    @StateObject private var vm = ChartViewModel()
    @State private var selectedTab: Int = 0

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {

                // MARK: HOW YOU SPEND
                sectionHeader(title: "How You Spend")

                spendingBarChart
                    .padding(.top, -8)

                // MARK: CATEGORIES DONUT
                sectionHeader(title: "Categories")

                CategoryDonutGlowChart(data: vm.categoryData)
                    .frame(height: 300)

                // MARK: CATEGORY TRANSACTIONS
                HStack {
                    Text(vm.selectedCategory.rawValue.capitalized)
                        .font(.title3.bold())
                        .foregroundColor(.white)

                    Spacer()

                    Text("Show All")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.body)
                }
                .padding(.top, 10)

                VStack(spacing: 16) {
                    ForEach(vm.transactions) { tx in
                        TransactionCardRow(tx: tx)
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
            }
        }
        .onChange(of: vm.selectedPeriod) { newValue in
            Task {
                switch newValue {
                case .weekly:
                    await vm.loadCurrentWeekSpending()
                case .monthly:
                    await vm.loadCurrentMonthSpending()
                }
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
        let data: [WeeklySpending] = {
            switch vm.selectedPeriod {
            case .weekly: return vm.weeklySpending
            case .monthly: return vm.monthlySpending
            }
        }()

        return Chart {
            ForEach(data) { item in
                BarMark(
                    x: .value(vm.selectedPeriod == .weekly ? "Day" : "Date", item.day),
                    y: .value("Amount", item.amount)
                )
                .foregroundStyle(Color.blue.opacity(0.7))
                .cornerRadius(8)
            }
        }
        .frame(height: 230)
        .padding()
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .chartYAxis {
            AxisMarks(position: .leading)
        }
    }
}
