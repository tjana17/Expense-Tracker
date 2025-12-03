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

    var body: some View {
        ZStack {

            Chart {
                ForEach(data) { item in
                    SectorMark(
                        angle: .value("Amount", item.amount),
                        innerRadius: .ratio(0.55),
                        angularInset: 3
                    )
                    .foregroundStyle(item.color)
                }
            }
            .chartLegend(.hidden)
            .frame(height: 250)

            // Center text
            VStack(spacing: 4) {
                Text("Food")
                    .foregroundColor(.white.opacity(0.7))
                    .font(.headline)
                Text("$7,589")
                    .font(.title.bold())
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .blue.opacity(0.4), radius: 20)
    }
}
