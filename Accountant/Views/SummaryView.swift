//
//  SummaryView.swift
//  Accountant
//
//  Created by Tarik Yasar on 3.11.2025.
//

import SwiftUI

struct SummaryView: View {
    @ObservedObject var store: TransactionStore
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Balance Card
                    VStack(spacing: 8) {
                        Text("Balance")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(formatAmount(store.balance))
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(store.balance >= 0 ? .green : .red)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                    )
                    
                    // Income and Expense Cards
                    HStack(spacing: 16) {
                        SummaryCard(
                            title: "Income",
                            amount: store.totalIncome,
                            color: .green,
                            icon: "arrow.down.circle.fill"
                        )
                        
                        SummaryCard(
                            title: "Expense",
                            amount: store.totalExpense,
                            color: .red,
                            icon: "arrow.up.circle.fill"
                        )
                    }
                    
                    // Recent Transactions
                    if !store.transactions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Transactions")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(store.transactions.sorted(by: { $0.date > $1.date }).prefix(5)) { transaction in
                                TransactionRow(transaction: transaction)
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemGray6))
                                    )
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Summary")
        }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        "₺\(formatTurkishCurrency(amount))"
    }
}

struct SummaryCard: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(formatAmount(amount))
                .font(.headline)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private func formatAmount(_ amount: Double) -> String {
        "₺\(formatTurkishCurrency(amount))"
    }
}

#Preview {
    SummaryView(store: TransactionStore())
}
