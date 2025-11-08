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
    
    var todayIncome: Double {
        let calendar = Calendar.current
        return transactions
            .filter { transaction in
                calendar.isDate(transaction.date, inSameDayAs: Date()) && transaction.type == .income
            }
            .map { $0.amount }
            .reduce(0, +)
    }
    
    var todayExpense: Double {
        let calendar = Calendar.current
        return transactions
            .filter { transaction in
                calendar.isDate(transaction.date, inSameDayAs: Date()) && transaction.type == .expense
            }
            .map { $0.amount }
            .reduce(0, +)
    }
    
    var todayBalance: Double {
        todayIncome - todayExpense
    }
    
    struct CategorySummary: Identifiable {
        let id = UUID()
        let category: String
        let amount: Double
        let color: Color
    }
    
    var expenseByCategory: [CategorySummary] {
        let grouped = Dictionary(grouping: transactions.filter { $0.type == .expense }) { $0.category }
        let colors: [Color] = [.red, .orange, .pink, .purple, .blue, .cyan, .teal, .mint]
        var colorIndex = 0
        
        return grouped.map { category, transactions in
            let total = transactions.reduce(0) { $0 + $1.amount }
            let color = colors[colorIndex % colors.count]
            colorIndex += 1
            return CategorySummary(category: category, amount: total, color: color)
        }
        .sorted { $0.amount > $1.amount }
    }
    
    var incomeByCategory: [CategorySummary] {
        let grouped = Dictionary(grouping: transactions.filter { $0.type == .income }) { $0.category }
        let colors: [Color] = [.green, .mint, .teal, .cyan, .blue]
        var colorIndex = 0
        
        return grouped.map { category, transactions in
            let total = transactions.reduce(0) { $0 + $1.amount }
            let color = colors[colorIndex % colors.count]
            colorIndex += 1
            return CategorySummary(category: category, amount: total, color: color)
        }
        .sorted { $0.amount > $1.amount }
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
