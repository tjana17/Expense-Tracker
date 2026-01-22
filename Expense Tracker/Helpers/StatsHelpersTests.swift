//
//  StatsHelpersTests.swift
//  Expense Tracker Tests
//
//  Created by Tests on 22/01/26.
//

import Testing
import SwiftUI
@testable import Expense_Tracker // Replace with your actual app module name if different.

@Suite("Stats helpers behavior")
struct StatsHelpersTests {

    @Test("Percent change increases and decreases")
    func percentChange_basic() {
        // 200 vs 100 -> +100% (1.0)
        #expect(abs(percentChange(current: 200, previous: 100) - 1.0) < 0.0001)

        // 50 vs 100 -> -50% (-0.5)
        #expect(abs(percentChange(current: 50, previous: 100) + 0.5) < 0.0001)

        // Same -> 0%
        #expect(percentChange(current: 100, previous: 100) == 0)

        // Previous = 0 -> uses epsilon, very large positive ratio
        let big = percentChange(current: 100, previous: 0)
        #expect(big > 1_000_000)
    }

    @Test("Formatted percent sign and rounding")
    func formattedPercent_rounding() {
        #expect(formattedPercent(0.0) == "+0%")
        #expect(formattedPercent(0.123) == "+12%")
        #expect(formattedPercent(0.125) == "+12%") // rounded
        #expect(formattedPercent(-0.074) == "-7%")
        #expect(formattedPercent(-0.075) == "-8%") // rounded
    }

    @Test("Trend color when increase is good (income)")
    func trendColor_income() {
        #expect(trendColor(change: 0.10, positiveIsGood: true) == .green)
        #expect(trendColor(change: -0.10, positiveIsGood: true) == .red)
        #expect(trendColor(change: 0.0, positiveIsGood: true) == .yellow)
    }

    @Test("Trend color when increase is bad (expense)")
    func trendColor_expense() {
        #expect(trendColor(change: 0.10, positiveIsGood: false) == .red)
        #expect(trendColor(change: -0.10, positiveIsGood: false) == .green)
        #expect(trendColor(change: 0.0, positiveIsGood: false) == .yellow)
    }
}
