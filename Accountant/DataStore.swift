//
//  DataStore.swift
//  Accountant
//
//  Created by Tarik Yasar on 3.11.2025.
//

import Foundation
import Combine
import SwiftUI

class TransactionStore: ObservableObject {
    @Published var transactions: [Transaction] = []
    
    private let saveKey = "SavedTransactions"
    
    init() {
        loadTransactions()
    }
    
    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
        saveTransactions()
    }
    
    func updateTransaction(_ transaction: Transaction) {
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            transactions[index] = transaction
            saveTransactions()
        }
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        transactions.removeAll { $0.id == transaction.id }
        saveTransactions()
    }
    
    func deleteTransaction(at offsets: IndexSet) {
        transactions.remove(atOffsets: offsets)
        saveTransactions()
    }
    
    func clearAllTransactions() {
        transactions.removeAll()
        saveTransactions()
    }
    
    var totalIncome: Double {
        transactions
            .filter { $0.type == .income }
            .map { $0.amount }
            .reduce(0, +)
    }
    
    var totalExpense: Double {
        transactions
            .filter { $0.type == .expense }
            .map { $0.amount }
            .reduce(0, +)
    }
    
    var balance: Double {
        totalIncome - totalExpense
    }
    
    private func saveTransactions() {
        if let encoded = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadTransactions() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Transaction].self, from: data) {
            transactions = decoded
        }
    }
}
