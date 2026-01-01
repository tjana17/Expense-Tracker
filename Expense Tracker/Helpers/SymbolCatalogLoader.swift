//
//  SymbolCatalogLoader.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 01/01/26.
//

import Foundation
import UIKit

enum SymbolCatalogLoader {

    // Load raw list from bundled JSON (array of strings) or from a .txt (one name per line).
    static func loadRawFromBundle() -> [String]? {
        let bundle = Bundle.main

        // Try JSON first
        if let url = bundle.url(forResource: "SFSymbols", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let array = try? JSONDecoder().decode([String].self, from: data) {
            return array
        }

        // Fallback: try .txt with one symbol name per line
        if let url = bundle.url(forResource: "SFSymbols", withExtension: "txt"),
           let text = try? String(contentsOf: url, encoding: .utf8) {
            let lines = text
                .components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty && !$0.hasPrefix("#") }
            return lines
        }

        return nil
    }

    // Filter to only those that are available on this device/OS
    static func filterAvailable(_ names: [String]) -> [String] {
        names.filter { UIImage(systemName: $0) != nil }
    }
}
