//
//  AddExpenseView.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 06/01/26.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AddExpenseView: View {
    // ViewModel for categories
    @StateObject private var categoriesVM = CategoriesViewModel()
    // New view model for saving expenses
    @StateObject private var vm = AddExpenseViewModel()
    // Access current user
    @EnvironmentObject private var authVM: AuthViewModel

    // Replace string options with Category array from Firestore
    @State private var selectedCategory: Category? = nil
    @State private var amountText: String = ""
    @State private var selectedDate: Date = Date()
    @State private var showDatePicker: Bool = false

    // Confirmation sheet
    @State private var showConfirmSheet: Bool = false

    @State private var selectedPaymentType: PaymentType = .cash

    // Toast state
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var toastStyle: ToastStyle = .success
    
    private var formattedDate: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: selectedDate)
    }

    // Simple validation for enabling the save button
    private var canSave: Bool {
        guard selectedCategory != nil else { return false }
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
                
                Text("Payment Type")
                    .font(.system(size: 20).weight(.bold))
                    .foregroundColor(.white)
                
                paymentTypeMenu

                // Date Field
                Text("Date")
                    .font(.system(size: 20).weight(.bold))
                    .foregroundColor(.white)

                datePicker

                // Save Expense triggers confirmation sheet first
                Button {
                    showConfirmSheet = true
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
        .sheet(isPresented: $showConfirmSheet) {
            confirmationSheet
                .presentationDetents([.height(320), .medium])
                .presentationCornerRadius(16)
        }
        // Reusable toast overlay
        .toast(isPresented: $showToast, message: toastMessage, style: toastStyle)
    }
    
    // MARK: - Category Dropdown
    private var categoryMenu: some View {
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
            .onAppear {
                guard let uid = authVM.user?.uid else { return }
                Task {
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
    }

    // MARK: - Payment Type Dropdown
    private var paymentTypeMenu: some View {
        Menu {
            ForEach(PaymentType.allCases) { type in
                Button {
                    selectedPaymentType = type
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: type.iconName)
                        Text(type.rawValue)
                            .font(.system(size: 20).bold())
                    }
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: selectedPaymentType.iconName)
                    .foregroundColor(.primary)
                Text(selectedPaymentType.rawValue)
                    .font(.system(size: 20).bold())
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .frame(height: 60)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    // MARK: - Amount Field
    private var amountField: some View {
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

    // MARK: - Confirmation Sheet
    private var confirmationSheet: some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(Color.secondary.opacity(0.4))
                .frame(width: 44, height: 5)
                .padding(.top, 8)

            Text("Confirm Expense")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                confirmItem(
                    icon: selectedCategory?.iconName ?? "folder",
                    title: "Category",
                    value: {
                        Text(selectedCategory?.name ?? "—")
                            .foregroundColor(.white)
                            .font(.body.bold())
                    }
                )

                confirmItem(
                    icon: "dollarsign.circle",
                    title: "Amount",
                    value: {
                        Text(formattedAmount(amountText))
                            .foregroundColor(.white)
                            .font(.body.bold())
                    }
                )

                confirmItem(
                    icon: selectedPaymentType.iconName,
                    title: "Payment Type",
                    value: {
                        Text(selectedPaymentType.rawValue)
                            .foregroundColor(.white)
                            .font(.body.bold())
                    }
                )

                confirmItem(
                    icon: "calendar",
                    title: "Date",
                    value: {
                        Text(formattedDate)
                            .foregroundColor(.white)
                            .font(.body.bold())
                    }
                )
            }
            .padding(12)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            HStack(spacing: 12) {
                Button {
                    showConfirmSheet = false
                } label: {
                    Text("Cancel")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.25))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    showConfirmSheet = false
                    Task { await saveExpense() }
                } label: {
                    Text("Confirm")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!canSave)
            }
        }
        .padding()
        .background(Color.black)
    }

    private func formattedAmount(_ text: String) -> String {
        if let value = Double(text.replacingOccurrences(of: ",", with: ".")) {
            let nf = NumberFormatter()
            nf.numberStyle = .currency
            nf.currencySymbol = "$"
            return nf.string(from: NSNumber(value: value)) ?? "$\(value)"
        }
        return "$0.00"
    }

    // MARK: - Save Button Actions
    private func saveExpense() async {
        guard let uid = authVM.user?.uid else {
            print("No authenticated user.")
            return
        }
        guard let category = selectedCategory else { return }
        guard let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")), amount > 0 else {
            print("Invalid amount")
            return
        }

        do {
            try await vm.saveExpense(
                userId: uid,
                categoryId: category.id,
                categoryName: category.name,
                categoryIcon: category.iconName,
                amount: amount,
                paymentType: selectedPaymentType.rawValue,
                date: selectedDate
            )
            print("Expense saved.")
            amountText = ""
            selectedDate = Date()
            selectedPaymentType = .cash

            // Show success toast locally
            showToast(message: "Expense saved successfully", style: .success)
        } catch {
            print("Failed to save expense: \(error.localizedDescription)")
            // Show error toast locally
            showToast(message: "Failed to save expense", style: .error)
        }
    }
    
    // MARK: - Local toast helper
    private func showToast(message: String, style: ToastStyle) {
        toastMessage = message
        toastStyle = style
        withAnimation {
            showToast = true
        }
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                withAnimation {
                    showToast = false
                }
            }
        }
    }
}

#Preview {
    AddExpenseView()
        .environmentObject(AuthViewModel())
}
