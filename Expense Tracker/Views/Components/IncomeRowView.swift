//
//  IncomeRowView.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 24/01/26.
//

import SwiftUI

struct IncomeRowView: View {
    let amountText: String
    let note: String
    let dateText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Amount in title font
            Text(amountText)
                .font(.title3.bold())
                .foregroundColor(.white)

            HStack(alignment: .firstTextBaseline) {
                // Note on the left (below amount)
                Text(note.isEmpty ? "—" : note)
                    .foregroundColor(.white.opacity(0.7))
                    .font(.subheadline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Spacer()

                // Date on the right
                Text(dateText)
                    .foregroundColor(.white.opacity(0.6))
                    .font(.caption)
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
