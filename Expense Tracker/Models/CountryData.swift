//
//  CountryData.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 09/12/25.
//

import Foundation
import SwiftUI

// MARK: - Country Data

struct CountryData: Equatable {
    let isoCode: String
    let name: String
    let dialCode: String
    let currencyName: String
    
    var flag: String {
        isoCode
            .uppercased()
            .unicodeScalars
            .map { 127397 + $0.value }
            .compactMap(UnicodeScalar.init)
            .map(String.init)
            .joined()
    }
    
    static let all: [CountryData] = [
        .init(isoCode: "US", name: "United States", dialCode: "1", currencyName: "USD - US Dollar"),
        .init(isoCode: "GB", name: "United Kingdom", dialCode: "44", currencyName: "GBP - Pound Sterling"),
        .init(isoCode: "CA", name: "Canada", dialCode: "1", currencyName: "CAD - Canadian Dollar"),
        .init(isoCode: "AU", name: "Australia", dialCode: "61", currencyName: "AUD - Australian Dollar"),
        .init(isoCode: "IN", name: "India", dialCode: "91", currencyName: "INR - Indian Rupee"),
        .init(isoCode: "SG", name: "Singapore", dialCode: "65", currencyName: "SGD - Singapore Dollar"),
        .init(isoCode: "EU", name: "European Union", dialCode: "388", currencyName: "EUR - Euro"),
        .init(isoCode: "JP", name: "Japan", dialCode: "81", currencyName: "JPY - Japanese Yen")
    ]
    
    static let defaultCountry: CountryData = {
        // Try to infer from current locale, else default to US
        let code = Locale.current.region?.identifier ?? "US"
        return all.first(where: { $0.isoCode == code }) ?? all.first { $0.isoCode == "US" }!
    }()
}
