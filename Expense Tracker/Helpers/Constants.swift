//
//  Constants.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 22/01/26.
//

import Foundation


// Currency formatter helper
public func formatCurrency(_ value: Double, symbol: String = "$") -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    formatter.groupingSeparator = "," // For thousands
    formatter.locale = Locale.current
    if let formatted = formatter.string(from: NSNumber(value: value)) {
        return "\(symbol)\(formatted)"
    } else {
        return "\(symbol)0.00"
    }
}

