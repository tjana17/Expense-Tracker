//
//  AddIncomeSheet.swift
//  Expense Tracker
//
//  Created by Your Name on 21/01/26.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AddIncomeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authVM: AuthViewModel

    @State private var amountText: String = ""
    @State private var date: Date = Date()
    @State private var note: String = ""
    @State private var isSaving: Bool = false
    @State private var saveError: String?

    // Validation
    private var amount: Double? {
        Double(amountText.replacingOccurrences(of: ",", with: "."))
    }
    private var amountError: String? {
        if amountText.isEmpty { return nil }
        guard let value = amount, value > 0 else { return "Enter a valid amount" }
        return nil
    }
    private var noteError: String? {
        if note.isEmpty { return nil }
        return note.count < 2 ? "Note is too short" : nil
    }
    private var isValid: Bool {
        guard let value = amount, value > 0 else { return false }
        return !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Add Income")
                    .font(.headline)
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.secondary)
            }

            // Amount Field
            VStack(alignment: .leading, spacing: 6) {
                TextField("Amount", text: $amountText)
                    .keyboardType(.decimalPad)
                    .autocorrectionDisabled(true)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.08))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                if let e = amountError {
                    Text(e)
                        .font(.caption)
                        .foregroundColor(.red)
                        .transition(.opacity)
                }
            }

            // Date Picker
            VStack(alignment: .leading, spacing: 6) {
                DatePicker("Date", selection: $date, displayedComponents: [.date])
                    .datePickerStyle(.compact)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.08))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            // Note Field
            VStack(alignment: .leading, spacing: 6) {
                TextField("Note", text: $note, axis: .vertical)
                    .autocorrectionDisabled(false)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.08))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                if let e = noteError {
                    Text(e)
                        .font(.caption)
                        .foregroundColor(.red)
                        .transition(.opacity)
                }
            }

            if let saveError {
                Text(saveError)
                    .font(.caption)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Submit Button
            Button {
                Task { await saveIncome() }
            } label: {
                HStack {
                    if isSaving {
                        ProgressView()
                            .tint(.white)
                    }
                    Text("Submit")
                        .bold()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isValid ? Color.blue : Color.gray.opacity(0.5))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!isValid || isSaving)

            Spacer()
        }
        .padding()
        .background(Color.black)
        .presentationBackground(.ultraThinMaterial)
    }

    private func saveIncome() async {
        guard let user = authVM.user else {
            saveError = "Not authenticated."
            return
        }
        guard let amount = amount, amount > 0 else {
            saveError = "Amount must be valid."
            return
        }
        let noteValue = note.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !noteValue.isEmpty else {
            saveError = "Note is required."
            return
        }

        saveError = nil
        isSaving = true
        defer { isSaving = false }

        let db = Firestore.firestore()
        let payload: [String: Any] = [
            "userId": user.uid,
            "amount": amount,
            "date": Timestamp(date: date),
            "note": noteValue,
            "createdAt": FieldValue.serverTimestamp()
        ]
        print(payload)

        do {
            // Save to flat 'incomes' collection with userId field
            _ = try await db.collection("incomes").addDocument(data: payload)
            dismiss()
        } catch {
            saveError = error.localizedDescription
        }
    }
}

#Preview {
    AddIncomeSheet()
        .preferredColorScheme(.dark)
        .environmentObject(AuthViewModel())
}



