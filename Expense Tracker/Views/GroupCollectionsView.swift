//
//  GroupCollectionsView.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 24/01/26.
//

import SwiftUI
import FirebaseAuth

struct GroupCollectionsView: View {
    // Access current user
    @EnvironmentObject private var authVM: AuthViewModel
    // ViewModel for categories
    @StateObject private var categoriesVM = CategoriesViewModel()
    // Layout: 3 columns for a 3x3 grid
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    
    var body: some View {
        ScrollView {
            CategoriesView()
            VStack {
                HStack {
                    Text("Income")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    Spacer()
                    Text("View All")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .onTapGesture {
                            Log.info("Income")
                        }
                }
            }
            VStack {
                HStack {
                    Text("Expenses")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    Spacer()
                    Text("View All")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .onTapGesture {
                            Log.info("Expenses")
                        }
                }
            }
        }
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            guard let uid = authVM.user?.uid else { return }
            Task {
                do {
                    try await categoriesVM.fetchCategoriesForUser(userId: uid)
                } catch {
                    print("Failed to fetch categories: \(error.localizedDescription)")
                }
            }
        }
    }
    
    fileprivate func CategoriesView() -> some View {
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Categories")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal)
                Spacer()
                Text("View All")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .onTapGesture {
                        Log.info("Categories")
                    }
            }
            
            if categoriesVM.categories.isEmpty {
                // Empty state
                VStack(spacing: 12) {
                    Image(systemName: "square.grid.2x2")
                        .font(.system(size: 36))
                        .foregroundColor(.white.opacity(0.6))
                    Text("No categories yet")
                        .foregroundColor(.white.opacity(0.8))
                    Text("Add some categories to get started.")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.footnote)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(categoriesVM.categories.prefix(9)) { category in
                        CategoryCard(category: category)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top, 16)
    }
}

struct CategoryCard: View {
    let category: Category

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 60, height: 60)
                Image(systemName: category.iconName.isEmpty ? "folder" : category.iconName)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }

            Text(category.name)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .contentShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    GroupCollectionsView()
        .environmentObject(AuthViewModel())
}
