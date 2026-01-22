//
//  StatsHelpers.swift
//  Expense Tracker
//
//  Created by Tests on 22/01/26.
//

import SwiftUI

// Reusable helpers for statsCards and related UI. Kept free functions for easy testability.

@inlinable
func percentChange(current: Double, previous: Double) -> Double {
    // (current - previous) / max(previous, epsilon) to avoid division by zero.
    let base = previous == 0 ? 0.000001 : previous
    return (current - previous) / base
}

@inlinable
func formattedPercent(_ value: Double) -> String {
    let pct = Int((value * 100).rounded())
    return (value >= 0 ? "+" : "") + "\(pct)%"
}

// UI-safe formatted percent using current and previous values directly.
// - Rounds to nearest percent.
// - Always shows a sign.
// - Handles previous == 0 to avoid exploding values.
@inlinable
func safeFormattedPercent(current: Double, previous: Double) -> String {
    // Both zero -> +0%
    if previous == 0, current == 0 {
        return "+0%"
    }
    // Previous zero and non-zero current -> cap to +100% (simple and bounded)
    if previous == 0 {
        return current >= 0 ? "+100%" : "-100%"
    }
    // Normal case: compute ratio and round to nearest percent
    let ratio = (current - previous) / previous
    let pct = Int((ratio * 100).rounded())
    let sign = pct >= 0 ? "+" : ""
    return "\(sign)\(pct)%"
}

// Choose color based on whether an increase is good or bad.
// For income (positiveIsGood: true): increase -> green, decrease -> red, flat -> yellow.
// For expenses (positiveIsGood: false): increase -> red, decrease -> green, flat -> yellow.
@inlinable
func trendColor(change: Double, positiveIsGood: Bool) -> Color {
    if change == 0 { return .yellow }
    if positiveIsGood {
        return change > 0 ? .green : .red
    } else {
        return change > 0 ? .red : .green
    }
}

