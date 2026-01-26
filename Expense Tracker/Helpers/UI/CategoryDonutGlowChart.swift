//
//  CategoryDonutGlowChart.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 30/11/25.
//

import SwiftUI
import Charts

struct CategoryDonutGlowChart: View {

    let data: [CategoryData]

    // Optional dynamic labels for center
    var title: String = "Summary"
    var income: Double = 0
    var expenses: Double = 0
    var savings: Double = 0
    var currencySymbol: String = "$"

    var body: some View {
        ZStack {

            Chart {
                ForEach(data) { item in
                    SectorMark(
                        angle: .value("Amount", max(item.amount, 0)),
                        innerRadius: .ratio(0.55),
                        angularInset: 3
                    )
                    .foregroundStyle(item.color)
                    // Glow effect per segment: layered shadows
                    .shadow(color: item.color.opacity(0.65), radius: 10)
                    .shadow(color: item.color.opacity(0.35), radius: 20)
                    .shadow(color: item.color.opacity(0.20), radius: 30)
                    // Subtle outer stroke to sharpen edges
                    .annotation(position: .overlay) {
                        Circle()
                            .stroke(item.color.opacity(0.25), lineWidth: 1)
                            .blur(radius: 0.5)
                            .opacity(0.6)
                            .blendMode(.plusLighter)
                            .allowsHitTesting(false)
                            .padding(1)
                    }
                }
            }
            .chartLegend(.hidden)
            .frame(height: 250)

            // Center text
            VStack(spacing: 6) {
                Text(title)
                    .foregroundColor(.white.opacity(0.7))
                    .font(.subheadline)

                VStack(spacing: 2) {
                    HStack(spacing: 8) {
                        Circle().fill(Color.blue).frame(width: 8, height: 8)
                        Text("Income \(formatCurrency(income, symbol: currencySymbol))")
                            .foregroundColor(.white.opacity(0.9))
                            .font(.caption)
                    }
                    HStack(spacing: 8) {
                        Circle().fill(Color.red).frame(width: 8, height: 8)
                        Text("Expenses \(formatCurrency(expenses, symbol: currencySymbol))")
                            .foregroundColor(.white.opacity(0.9))
                            .font(.caption)
                    }
                    HStack(spacing: 8) {
                        Circle().fill(Color.green).frame(width: 8, height: 8)
                        Text("Savings \(formatCurrency(savings, symbol: currencySymbol))")
                            .foregroundColor(.white)
                            .font(.caption.bold())
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        // Outer glow for the whole card
        .shadow(color: .blue.opacity(0.25), radius: 18)
        .shadow(color: .green.opacity(0.18), radius: 12)
    }
}

