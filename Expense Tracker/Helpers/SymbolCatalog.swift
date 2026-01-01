//
//  SymbolCatalog.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 01/01/26.
//

import Foundation

enum SymbolCatalog {

    // Prefer the bundled full list (iOS 16 export), filtered for availability.
    // Falls back to the curated list below if the resource is missing.
    static var all: [String] {
        if let raw = SymbolCatalogLoader.loadRawFromBundle() {
            let filtered = SymbolCatalogLoader.filterAvailable(raw)
            if !filtered.isEmpty {
                return filtered
            }
        }
        // Fallback curated list
        return fallbackCurated
    }

    // Your existing curated list (safe fallback)
    private static let fallbackCurated: [String] = [
        "cart", "cart.fill", "fork.knife", "takeoutbag.and.cup.and.straw",
        "house", "house.fill", "car.fill", "tram.fill", "bicycle",
        "airplane", "bus.fill", "fuelpump.fill",
        "heart.fill", "cross.case.fill", "pill.fill", "stethoscope",
        "gamecontroller.fill", "film.fill", "music.note.list",
        "hammer.fill", "wrench.and.screwdriver.fill", "briefcase.fill",
        "laptopcomputer", "desktopcomputer", "ipad.and.iphone",
        "gift.fill", "tshirt.fill", "bag.fill", "bag", "shippingbox.fill",
        "creditcard.fill", "banknote.fill", "dollarsign.circle.fill",
        "chart.pie.fill", "chart.line.uptrend.xyaxis",
        "leaf.fill", "sun.max.fill", "moon.fill",
        "bolt.fill", "flame.fill", "drop.fill",
        "globe", "mappin.and.ellipse", "location.fill",
        "book.fill", "graduationcap.fill",
        "doc.text.fill", "calendar", "clock.fill",
        "paintpalette.fill", "scissors", "camera.fill",
        "photo.fill", "sparkles", "star.fill",
        "tram.fill", "bicycle", "scooter",
        "cup.and.saucer.fill", "wineglass.fill",
        "bed.double.fill", "house.lodge.fill",
        "pawprint.fill", "leaf.fill", "tree.fill",
        "cart.badge.plus", "cart.badge.minus",
        "shippingbox.and.arrow.backward.fill",
        "fuelpump.slash.fill",
        "figure.walk", "figure.run", "dumbbell",
        "theatermasks.fill", "gamecontroller.fill",
        "tv.fill", "display", "headphones",
        "wallet.pass.fill", "wallet.bifold",
        "folder", "folder.fill"
    ]
}
