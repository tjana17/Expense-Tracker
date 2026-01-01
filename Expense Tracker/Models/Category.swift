//
//  Category.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 01/01/26.
//

import Foundation

struct Category: Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var iconName: String

    init(id: UUID = UUID(), name: String, iconName: String) {
        self.id = id
        self.name = name
        self.iconName = iconName
    }
}
