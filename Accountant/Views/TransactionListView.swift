//
//  TransactionListView.swift
//  Accountant
//
//  Created by Tarik Yasar on 3.11.2025.
//

import SwiftUI
import UniformTypeIdentifiers

struct TransactionListView: View {
    @ObservedObject var store: TransactionStore
    @State private var showingAddTransaction = false
    @State private var editingTransaction: Transaction?
    @State private var showingClearAlert = false
    @State private var exportFile: ExportFile?
    
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
                if !store.transactions.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            exportTransactions()
                        }) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .help("Export transactions to CSV")
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        showingClearAlert = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddTransaction = true
                    }) {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.plain)
                }
            }
            .fileExporter(
                isPresented: Binding(
                    get: { exportFile != nil },
                    set: { if !$0 { exportFile = nil } }
                ),
                document: exportFile,
                contentType: .commaSeparatedText,
                defaultFilename: "transactions"
            ) { result in
                if case .failure(let error) = result {
                    print("Export failed: \(error.localizedDescription)")
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
    
    private func exportTransactions() {
        let csvContent = generateCSVContent()
        exportFile = ExportFile(content: csvContent)
    }
    
    private func generateCSVContent() -> String {
        let header = "Date,Name,Category,Type,Amount\n"
        
        let rows = store.transactions.sorted(by: { $0.date > $1.date }).map { transaction in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: transaction.date)
            
            // Escape name and category if they contain commas or quotes
            let name = escapeCSVField(transaction.description)
            let category = escapeCSVField(transaction.category)
            let type = transaction.type.rawValue
            let amount = String(format: "%.2f", transaction.amount)
            
            return "\(dateString),\(name),\(category),\(type),\(amount)"
        }
        
        return header + rows.joined(separator: "\n")
    }
    
    private func escapeCSVField(_ field: String) -> String {
        // If field contains comma, quote, or newline, wrap in quotes and escape quotes
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            return "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return field
    }
}

struct ExportFile: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText] }
    
    var content: String
    
    init(content: String) {
        self.content = content
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents,
           let string = String(data: data, encoding: .utf8) {
            content = string
        } else {
            content = ""
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = content.data(using: .utf8) ?? Data()
        return FileWrapper(regularFileWithContents: data)
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
