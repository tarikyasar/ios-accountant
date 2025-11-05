//
//  TransactionListView.swift
//  Accountant
//
//  Created by Tarik Yasar on 3.11.2025.
//

import SwiftUI

struct TransactionListView: View {
    @ObservedObject var store: TransactionStore
    @State private var showingAddTransaction = false
    @State private var editingTransaction: Transaction?
    @State private var showingClearAlert = false
    
    var body: some View {
        NavigationView {
            List {
                if store.transactions.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "list.bullet.clipboard")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No transactions yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Tap + to add your first transaction")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(store.transactions.sorted(by: { $0.date > $1.date })) { transaction in
                        TransactionRow(transaction: transaction)
                            .onTapGesture {
                                editingTransaction = transaction
                            }
                    }
                    .onDelete(perform: deleteTransactions)
                }
            }
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !store.transactions.isEmpty {
                        Button(action: {
                            showingClearAlert = true
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddTransaction = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView(store: store)
            }
            .sheet(item: $editingTransaction) { transaction in
                AddTransactionView(store: store, editingTransaction: transaction)
            }
            .alert("Clear All Entries", isPresented: $showingClearAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    store.clearAllTransactions()
                }
            } message: {
                Text("Are you sure you want to delete all transactions? This action cannot be undone.")
            }
        }
    }
    
    private func deleteTransactions(at offsets: IndexSet) {
        let sortedTransactions = store.transactions.sorted(by: { $0.date > $1.date })
        for index in offsets {
            store.deleteTransaction(sortedTransactions[index])
        }
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description)
                    .font(.headline)
                Text(transaction.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(transaction.date, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(formatAmount(transaction.amount))
                .font(.headline)
                .foregroundColor(transaction.type == .income ? .green : .red)
        }
        .padding(.vertical, 4)
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let sign = transaction.type == .income ? "+" : "-"
        let formatted = formatTurkishCurrency(abs(amount))
        return "\(sign)₺\(formatted)"
    }
}

#Preview {
    TransactionListView(store: TransactionStore())
}
