//
//  AddExpenseView.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 06/01/26.
//

import SwiftUI
import FirebaseAuth

struct AddExpenseView: View {
    // ViewModel for categories
    @StateObject private var categoriesVM = CategoriesViewModel()
    // Access current user
    @EnvironmentObject private var authVM: AuthViewModel

    // Replace string options with Category array from Firestore
    @State private var selectedCategory: Category? = nil
    @State private var amountText: String = ""
    @State private var selectedDate: Date = Date()
    @State private var showDatePicker: Bool = false

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: selectedDate)
    }

    // Simple validation for enabling the save button
    private var canSave: Bool {
        guard selectedCategory != nil else { return false }
        // check a valid decimal amount > 0
        if let value = Double(amountText.replacingOccurrences(of: ",", with: ".")), value > 0 {
            return true
        }
        return false
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Category")
                    .font(.system(size: 20).weight(.bold))
                    .foregroundColor(.white)

                // Menu to select categories
                categoryMenu

                // Amount Field
                Text("Amount")
                    .font(.system(size: 20).weight(.bold))
                    .foregroundColor(.white)

                amountField

                // Date Field
                Text("Date")
                    .font(.system(size: 20).weight(.bold))
                    .foregroundColor(.white)

                datePicker

                // Save Expense (moved here, right after the date field)
                Button {
                    saveExpense()
                } label: {
                    Text("Save Expense")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(canSave ? Color.blue : Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!canSave)
                .padding(.top, 20)

                Spacer(minLength: 12)
            }
            .padding()
            .background(.black)
            .navigationTitle("Add Expense")
        }
        .background(.black)
    }
    
    // MARK: - Category Dropdown
    private var categoryMenu: some View {
        // Menu with custom label field
        Menu {
            ForEach(categoriesVM.categories, id: \.self) { category in
                Button {
                    selectedCategory = category
                } label: {
                    HStack(spacing: 20) {
                        Image(systemName: category.iconName)
                        Text(category.name)
                            .font(.system(size: 20).bold())
                    }
                }
            }
        } label: {
            HStack(spacing: 12) {
                if let cat = selectedCategory ?? categoriesVM.categories.first {
                    Image(systemName: cat.iconName)
                        .foregroundColor(.primary)
                    Text(cat.name)
                        .font(.system(size: 20).bold())
                        .foregroundColor(.primary)
                } else {
                    Text("Select Category")
                        .foregroundColor(.secondary)
                        .font(.system(size: 20).bold())
                }
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .frame(height: 60)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .task {
            // Fetch categories when the view appears and user is available
            if let uid = authVM.user?.uid {
                do {
                    try await categoriesVM.fetchCategoriesForUser(userId: uid)
                    if selectedCategory == nil {
                        selectedCategory = categoriesVM.categories.first
                    }
                } catch {
                    print("Failed to fetch categories: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Amount Field
    private var amountField: some View {
        // Amount TextField with leading $ and trailing clear button
        HStack(spacing: 8) {
            Text("$")
                .foregroundColor(.secondary)
                .font(.system(size: 20).weight(.bold))

            TextField("0.00", text: $amountText)
                .keyboardType(.decimalPad)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 20).weight(.bold))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .frame(height: 60)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .overlay(
            HStack {
                Spacer()
                if !amountText.isEmpty {
                    Button {
                        amountText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .padding(.trailing, 10)
                    .accessibilityLabel("Clear amount")
                }
            }
        )
    }
    
    // MARK: - Datepicker
    private var datePicker: some View {
        // Read-only "textfield" style with trailing calendar icon; taps open a date picker
        Button {
            showDatePicker = true
        } label: {
            HStack(spacing: 12) {
                Text(formattedDate)
                    .foregroundColor(.primary)
                    .font(.system(size: 20).weight(.bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: -10))

                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .frame(height: 60)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showDatePicker) {
            NavigationStack {
                VStack {
                    DatePicker(
                        "Select Date",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .padding()

                    Spacer()
                }
                .navigationTitle("Choose Date")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            showDatePicker = false
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showDatePicker = false
                        }
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
    }

    // MARK: - Actions
    private func saveExpense() {
        // Implement your save logic here:
        // - Validate fields (already covered by canSave)
        // - Parse amount
        // - Build expense payload
        // - Write to Firestore if needed
        // - Dismiss or show confirmation

        guard let category = selectedCategory else { return }
        let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0
        print("Saving expense with category: \(category.name), icon: \(category.iconName), amount: \(amount), date: \(selectedDate)")
    }
}

#Preview {
    AddExpenseView()
        .environmentObject(AuthViewModel())
}

