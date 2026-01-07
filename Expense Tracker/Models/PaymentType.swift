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
