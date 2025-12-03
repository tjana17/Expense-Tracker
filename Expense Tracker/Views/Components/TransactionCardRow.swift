//
//  TransactionCardRow.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 03/12/25.
//

import SwiftUI

struct TransactionCardRow: View {

    let tx: TransactionItem

    var body: some View {
        HStack {

            ZStack {
                Circle()
                    .fill(tx.category.color.opacity(0.18))
                    .frame(width: 54, height: 54)

                Image(systemName: "tx.category.icon")
                    .foregroundColor(tx.category.color)
                    .font(.title2)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(tx.title)
                    .foregroundColor(.white)
                    .font(.headline)

                Text(tx.dateString)
                    .foregroundColor(.white.opacity(0.6))
                    .font(.caption)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(tx.amountString)
                    .foregroundColor(tx.isPositive ? .green : .red)
                    .font(.headline)

                Text("Cash")
                    .foregroundColor(.white.opacity(0.5))
                    .font(.caption)
            }
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }
}
