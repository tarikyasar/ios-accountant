//
//  Transaction.swift
//  Accountant
//
//  Created by Tarik Yasar on 3.11.2025.
//

import Foundation

struct Transaction: Identifiable, Codable {
    let id: UUID
    var amount: Double
    var description: String
    var category: String
    var type: TransactionType
    var date: Date
    
    init(id: UUID = UUID(), amount: Double, description: String, category: String, type: TransactionType, date: Date = Date()) {
        self.id = id
        self.amount = amount
        self.description = description
        self.category = category
        self.type = type
        self.date = date
    }
}

enum TransactionType: String, Codable, CaseIterable {
    case income = "Income"
    case expense = "Expense"
}

struct Category: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
}

extension Category {
    static let expenseCategories: [Category] = [
        Category(name: "Food", icon: "fork.knife"),
        Category(name: "Transport", icon: "car.fill"),
        Category(name: "Shopping", icon: "bag.fill"),
        Category(name: "Bills", icon: "doc.text.fill"),
        Category(name: "Entertainment", icon: "tv.fill"),
        Category(name: "Health", icon: "heart.fill"),
        Category(name: "Education", icon: "book.fill"),
        Category(name: "Other", icon: "ellipsis.circle.fill")
    ]
    
    static let incomeCategories: [Category] = [
        Category(name: "Salary", icon: "dollarsign.circle.fill"),
        Category(name: "Freelance", icon: "briefcase.fill"),
        Category(name: "Investment", icon: "chart.line.uptrend.xyaxis"),
        Category(name: "Gift", icon: "gift.fill"),
        Category(name: "Other", icon: "ellipsis.circle.fill")
    ]
}
