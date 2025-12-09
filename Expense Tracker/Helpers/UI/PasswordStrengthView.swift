//
//  PasswordStrengthView.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 09/12/25.
//

import SwiftUI

// MARK: - Password Strength

enum PasswordStrength {
    // Returns score 0...4
    static func score(for password: String) -> Int {
        var s = 0
        if password.count >= 8 { s += 1 }
        if password.rangeOfCharacter(from: .uppercaseLetters) != nil { s += 1 }
        if password.rangeOfCharacter(from: .lowercaseLetters) != nil { s += 1 }
        if password.rangeOfCharacter(from: .decimalDigits) != nil { s += 1 }
        if password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()-_=+[]{};:'\",.<>/?`~|\\")) != nil { s += 1 }
        return min(s, 4)
    }
    
    static func description(for score: Int) -> String {
        switch score {
        case 0,1: return "Very Weak"
        case 2: return "Weak"
        case 3: return "Good"
        default: return "Strong"
        }
    }
    
    static func color(for score: Int) -> Color {
        switch score {
        case 0,1: return .red
        case 2: return .orange
        case 3: return .yellow
        default: return .green
        }
    }
}

struct PasswordStrengthView: View {
    let score: Int
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            GeometryReader { geo in
                HStack(spacing: 4) {
                    ForEach(0..<4, id: \.self) { idx in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(idx < score ? PasswordStrength.color(for: score) : Color.gray.opacity(0.3))
                            .frame(width: (geo.size.width - 12) / 4, height: 6)
                    }
                }
            }
            .frame(height: 6)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    PasswordStrengthView(score: 0, description: "")
}
