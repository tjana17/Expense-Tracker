//
//  GeneralAddView.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 24/01/26.
//

import SwiftUI

struct GeneralAddView: View {
    // Sheet states
    @State private var showAddCategorySheet = false
    @State private var showAddIncomeSheet = false
    // Navigation
    @State private var goToAddExpense = false

    // Grid layout: 2 columns
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Quick Add")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                        cardButton(
                            title: "Category",
                            systemImage: "square.grid.2x2.fill",
                            tint: .blue
                        ) {
                            showAddCategorySheet = true
                        }

                        cardButton(
                            title: "Income",
                            systemImage: "tray.and.arrow.down.fill",
                            tint: .green
                        ) {
                            showAddIncomeSheet = true
                        }

                        cardButton(
                            title: "Expense",
                            systemImage: "creditcard.fill",
                            tint: .red
                        ) {
                            goToAddExpense = true
                        }
                    }
                }
                .padding()
            }
            .background(Color.black.ignoresSafeArea())
            .navigationDestination(isPresented: $goToAddExpense) {
                AddExpenseView()
            }
            .sheet(isPresented: $showAddCategorySheet) {
                AddCategorySheet()
                    .presentationDetents([.medium, .large])
                    .presentationCornerRadius(16)
            }
            .sheet(isPresented: $showAddIncomeSheet) {
                AddIncomeSheet()
                    .presentationDetents([.medium])
                    .presentationCornerRadius(16)
            }
            .navigationTitle("Add")
            .toolbarTitleDisplayMode(.inline)
        }
        .background(Color.black)
    }

    // MARK: - Card Button
    @ViewBuilder
    private func cardButton(title: String, systemImage: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(tint.opacity(0.18))
                        .frame(height: 60)
                    Image(systemName: systemImage)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(tint)
                }
                Text(title)
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .padding(14)
            .background(Color.white.opacity(0.06))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    GeneralAddView()
}

