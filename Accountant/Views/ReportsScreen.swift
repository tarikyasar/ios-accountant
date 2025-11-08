//
//  ReportsScreen.swift
//  Accountant
//
//  Created by Tarik Yasar on 3.11.2025.
//

import SwiftUI
import Charts

struct ReportsScreen: View {
    @ObservedObject var store: TransactionStore
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Daily Report Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                            Text("Daily Report")
                                .font(.headline)
                        }
                        
                        HStack(spacing: 16) {
                            DailyReportCard(
                                title: "Today's Income",
                                amount: store.todayIncome,
                                color: .green,
                                icon: "arrow.down.circle.fill"
                            )
                            
                            DailyReportCard(
                                title: "Today's Expense",
                                amount: store.todayExpense,
                                color: .red,
                                icon: "arrow.up.circle.fill"
                            )
                        }
                        
                        VStack(spacing: 8) {
                            Text("Today's Balance")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(formatAmount(store.todayBalance))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(store.todayBalance >= 0 ? .green : .red)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
                    
                    // Expense Pie Chart
                    if !store.expenseByCategory.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "chart.pie.fill")
                                    .foregroundColor(.red)
                                Text("Expenses by Category")
                                    .font(.headline)
                            }
                            
                            ExpensePieChart(data: store.expenseByCategory, total: store.totalExpense)
                                .frame(height: 300)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        )
                    }
                    
                    // Income Pie Chart
                    if !store.incomeByCategory.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "chart.pie.fill")
                                    .foregroundColor(.green)
                                Text("Income by Category")
                                    .font(.headline)
                            }
                            
                            IncomePieChart(data: store.incomeByCategory, total: store.totalIncome)
                                .frame(height: 300)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Reports")
        }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        "₺\(formatTurkishCurrency(amount))"
    }
}

struct DailyReportCard: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text(formatAmount(amount))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
    
    private func formatAmount(_ amount: Double) -> String {
        "₺\(formatTurkishCurrency(amount))"
    }
}

struct ExpensePieChart: View {
    let data: [TransactionStore.CategorySummary]
    let total: Double
    
    var body: some View {
        VStack(spacing: 16) {
            Chart(data, id: \.id) { item in
                SectorMark(
                    angle: .value("Amount", item.amount),
                    innerRadius: .ratio(0.5),
                    angularInset: 2
                )
                .foregroundStyle(item.color)
                .annotation(position: .overlay) {
                    if item.amount / total > 0.1 {
                        Text(String(format: "%.0f%%", (item.amount / total) * 100))
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(height: 200)
            
            // Legend
            VStack(alignment: .leading, spacing: 8) {
                ForEach(data) { item in
                    HStack {
                        Circle()
                            .fill(item.color)
                            .frame(width: 12, height: 12)
                        
                        Text(item.category)
                            .font(.caption)
                        
                        Spacer()
                        
                        Text(formatAmount(item.amount))
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        "₺\(formatTurkishCurrency(amount))"
    }
}

struct IncomePieChart: View {
    let data: [TransactionStore.CategorySummary]
    let total: Double
    
    var body: some View {
        VStack(spacing: 16) {
            Chart(data, id: \.id) { item in
                SectorMark(
                    angle: .value("Amount", item.amount),
                    innerRadius: .ratio(0.5),
                    angularInset: 2
                )
                .foregroundStyle(item.color)
                .annotation(position: .overlay) {
                    if item.amount / total > 0.1 {
                        Text(String(format: "%.0f%%", (item.amount / total) * 100))
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(height: 200)
            
            // Legend
            VStack(alignment: .leading, spacing: 8) {
                ForEach(data) { item in
                    HStack {
                        Circle()
                            .fill(item.color)
                            .frame(width: 12, height: 12)
                        
                        Text(item.category)
                            .font(.caption)
                        
                        Spacer()
                        
                        Text(formatAmount(item.amount))
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func formatAmount(_ amount: Double) -> String {
        "₺\(formatTurkishCurrency(amount))"
    }
}

#Preview {
    ReportsScreen(store: TransactionStore())
}
