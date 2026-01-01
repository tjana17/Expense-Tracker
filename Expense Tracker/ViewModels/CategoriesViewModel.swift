//
//  CategoriesViewModel.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 01/01/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class CategoriesViewModel: ObservableObject {
    @Published private(set) var categories: [Category] = []

    // Validation: name must be at least 3 visible characters
    func isValidName(_ name: String) -> Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3
    }

    func addCategory(name: String, iconName: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isValidName(trimmed) else { return false }

        // Avoid duplicates by name (case-insensitive)
        if categories.contains(where: { $0.name.lowercased() == trimmed.lowercased() }) {
            return false
        }

        let new = Category(name: trimmed, iconName: iconName)
        categories.append(new)
        return true
    }
}
