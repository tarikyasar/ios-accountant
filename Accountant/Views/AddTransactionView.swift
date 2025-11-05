//
//  AddTransactionView.swift
//  Accountant
//
//  Created by Tarik Yasar on 3.11.2025.
//

import SwiftUI

struct AddTransactionView: View {
    @ObservedObject var store: TransactionStore
    @Environment(\.dismiss) var dismiss
    
    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var selectedCategory: String = ""
    @State private var transactionType: TransactionType = .expense
    @State private var date: Date = Date()
    
    var editingTransaction: Transaction?
    
    init(store: TransactionStore, editingTransaction: Transaction? = nil) {
        self.store = store
        self.editingTransaction = editingTransaction
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Type") {
                    Picker("Transaction Type", selection: $transactionType) {
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Details") {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    TextField("Description", text: $description)
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(availableCategories) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.name)
                            }
                            .tag(category.name)
                        }
                    }
                }
            }
            .navigationTitle(editingTransaction == nil ? "Add Transaction" : "Edit Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTransaction()
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                if let transaction = editingTransaction {
                    amount = String(format: "%.2f", transaction.amount)
                    description = transaction.description
                    selectedCategory = transaction.category
                    transactionType = transaction.type
                    date = transaction.date
                } else {
                    updateDefaultCategory()
                }
            }
            .onChange(of: transactionType) { _ in
                updateDefaultCategory()
            }
        }
    }
    
    private var availableCategories: [Category] {
        transactionType == .income ? Category.incomeCategories : Category.expenseCategories
    }
    
    private func updateDefaultCategory() {
        if transactionType == .income {
            selectedCategory = "Salary"
        } else {
            selectedCategory = "Food"
        }
    }
    
    private var isValid: Bool {
        !amount.isEmpty && Double(amount) != nil && !description.isEmpty && !selectedCategory.isEmpty
    }
    
    private func saveTransaction() {
        guard let amountValue = Double(amount) else { return }
        
        let transaction = Transaction(
            id: editingTransaction?.id ?? UUID(),
            amount: amountValue,
            description: description,
            category: selectedCategory,
            type: transactionType,
            date: date
        )
        
        if editingTransaction != nil {
            store.updateTransaction(transaction)
        } else {
            store.addTransaction(transaction)
        }
        
        dismiss()
    }
}

#Preview {
    AddTransactionView(store: TransactionStore())
}
