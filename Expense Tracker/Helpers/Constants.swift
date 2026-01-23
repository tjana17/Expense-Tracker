//
//  Constants.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 22/01/26.
//

import Foundation
import SwiftUI

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

// Deterministic "random" color per icon string to avoid flicker
func colorForIcon(_ icon: String) -> Color {
    let hue = normalizedHash(icon)
    // Keep saturation/brightness in pleasant ranges for dark background
    return Color(hue: hue, saturation: 0.65, brightness: 0.95)
}

// Hash a string to a value in 0...1 for hue
func normalizedHash(_ s: String) -> Double {
    var hasher = Hasher()
    hasher.combine(s)
    let hash = hasher.finalize()
    // Map Int to 0...1
    let positive = abs(Int64(hash))
    // Use a large prime to distribute, then modulo 360 for hue degrees
    let hueDegrees = Double(positive % 360)
    return hueDegrees / 360.0
}

// Safe date formatting for optional Date?
func formattedDate(_ date: Date?) -> String {
    guard let date else { return "—" }
    let f = DateFormatter()
    f.dateStyle = .medium
    f.timeStyle = .short
    return f.string(from: date)
}
