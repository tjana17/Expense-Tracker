//
//  TransactionRowView.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 23/01/26.
//

import SwiftUI

struct TransactionRowView: View {
    let systemIconName: String
    let title: String
    let subtitle: String
    let amountText: String
    let tint: Color
    let accessoryText: String?
    let isPositive: Bool

    init(
        systemIconName: String,
        title: String,
        subtitle: String,
        amountText: String,
        tint: Color,
        accessoryText: String? = "Cash",
        isPositive: Bool = false
    ) {
        self.systemIconName = systemIconName
        self.title = title
        self.subtitle = subtitle
        self.amountText = amountText
        self.tint = tint
        self.accessoryText = accessoryText
        self.isPositive = isPositive
    }

    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.15))
                    .frame(width: 50, height: 50)
                Image(systemName: systemIconName)
                    .foregroundColor(tint)
            }

            VStack(alignment: .leading) {
                Text(title)
                    .foregroundColor(.white)
                    .font(.headline)

                Text(subtitle)
                    .foregroundColor(.white.opacity(0.6))
                    .font(.caption)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(amountText)
                    .foregroundColor(.white)
                if let accessoryText {
                    Text(accessoryText)
                        .foregroundColor(.white.opacity(0.5))
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 16) {
            TransactionRowView(
                systemIconName: "cart.fill",
                title: "Groceries",
                subtitle: "Jan 23, 10:21 AM",
                amountText: "$45.20",
                tint: .green,
                accessoryText: "Cash",
                isPositive: false
            )
            TransactionRowView(
                systemIconName: "dollarsign.circle.fill",
                title: "Salary",
                subtitle: "Jan 20, 9:00 AM",
                amountText: "+$2,500.00",
                tint: .blue,
                accessoryText: "Bank",
                isPositive: true
            )
        }
        .padding()
    }
}
