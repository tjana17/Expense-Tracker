//
//  AddCategorySheet.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 01/01/26.
//

import SwiftUI

struct AddCategorySheet: View {
    // If you later promote this VM to EnvironmentObject, replace with @EnvironmentObject
    @StateObject private var vm = CategoriesViewModel()

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var selectedIcon: String = "folder"
    @State private var searchText: String = ""

    private var nameError: String? {
        if name.isEmpty { return nil } // don’t show until user types
        return vm.isValidName(name) ? nil : "Name must be at least 3 characters"
    }

    // Centralized SFSymbols list (loaded from bundle if available, else curated fallback)
    private var allSymbols: [String] { SymbolCatalog.all }

    private var filteredSymbols: [String] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return allSymbols }
        return allSymbols.filter { $0.lowercased().contains(q) }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Add Category")
                    .font(.headline)
                Spacer()
                Button("Cancel") { dismiss() }
                    .foregroundColor(.secondary)
            }

            // Name field
            VStack(alignment: .leading, spacing: 6) {
                TextField("Category name", text: $name)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled(true)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.08))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                if let e = nameError {
                    Text(e)
                        .font(.caption)
                        .foregroundColor(.red)
                        .transition(.opacity)
                }
            }

            // Selected icon preview
            HStack(spacing: 12) {
                Text("Selected Icon")
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
                Image(systemName: selectedIcon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.white.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // Icon search
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search symbols", text: $searchText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            // Symbols grid
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12) {
                    ForEach(filteredSymbols, id: \.self) { sym in
                        Button {
                            selectedIcon = sym
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(sym == selectedIcon ? Color.blue.opacity(0.35) : Color.white.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(sym == selectedIcon ? Color.blue : Color.clear, lineWidth: 1)
                                    )
                                Image(systemName: sym)
                                    .foregroundColor(.white)
                                    .padding(10)
                            }
                            .frame(height: 44)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 4)
            }
            .frame(maxHeight: 260)

            // Save button
            Button {
                let saved = vm.addCategory(name: name, iconName: selectedIcon)
                if saved {
                    dismiss()
                }
            } label: {
                Text("Save")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(saveEnabled ? Color.blue : Color.gray.opacity(0.5))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!saveEnabled)
        }
        .padding()
        .background(Color.black)
        .presentationBackground(.ultraThinMaterial)
    }

    private var saveEnabled: Bool {
        vm.isValidName(name) && !selectedIcon.isEmpty
    }
}

#Preview {
    AddCategorySheet()
        .preferredColorScheme(.dark)
}
