//
//  PaymentType.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 07/01/26.
//

import Foundation

// Payment Type enum and selection
enum PaymentType: String, CaseIterable, Identifiable {
    case cash = "Cash"
    case card = "Card"
    case online = "Online"
    case upi = "UPI"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .cash: return "banknote"
        case .card: return "creditcard"
        case .online: return "arrow.left.arrow.right.circle"
        case .upi: return "qrcode.viewfinder"
        }
    }
}

// Currency Symbol for selected currency
enum Currency {
    static func symbol(from code: String) -> String {
        switch code {
        case "USD - US Dollar": return "$"
        case "EUR - Euro": return "€"
        case "GBP - Pound Sterling": return "£"
        case "JPY - Japanese Yen": return "¥"
        case "INR - Indian Rupee": return "₹"
        default: return "$"
        }
    }
}
