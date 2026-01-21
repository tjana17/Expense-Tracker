//
//  Income.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 21/01/26.
//

import Foundation

struct Income: Identifiable, Codable {
    var id: String { uid }
    let uid: String
    let amount: Double
    let date: Date?
    let createdAt: Date?
    let note: String
}
