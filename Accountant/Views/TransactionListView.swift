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
    @State private var selectedType: TransactionTypeFilter = .all
    @State private var selectedCategory: String = "All"
    @State private var showingFilters = false
    
    enum TransactionTypeFilter: String, CaseIterable {
        case all = "All"
        case income = "Income"
        case expense = "Expense"
    }
    
    var filteredTransactions: [Transaction] {
        var transactions = store.transactions
        
        // Filter by type
        if selectedType != .all {
            transactions = transactions.filter { $0.type.rawValue == selectedType.rawValue }
        }
        
        // Filter by category
        if selectedCategory != "All" {
            transactions = transactions.filter { $0.category == selectedCategory }
        }
        
        return transactions.sorted(by: { $0.date > $1.date })
    }
    
    var availableCategories: [String] {
        var categories = Set<String>()
        let filtered = selectedType == .all 
            ? store.transactions 
            : store.transactions.filter { $0.type.rawValue == selectedType.rawValue }
        
        categories = Set(filtered.map { $0.category })
        return ["All"] + Array(categories).sorted()
    }
    
    var isFilterActive: Bool {
        selectedType != .all || selectedCategory != "All"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Active Filters Display
                if isFilterActive && !showingFilters {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            if selectedType != .all {
                                FilterChip(
                                    label: selectedType.rawValue,
                                    icon: selectedType == .income ? "arrow.down.circle.fill" : "arrow.up.circle.fill",
                                    color: selectedType == .income ? .green : .red
                                ) {
                                    selectedType = .all
                                }
                            }
                            
                            if selectedCategory != "All" {
                                FilterChip(
                                    label: selectedCategory,
                                    icon: "tag.fill",
                                    color: .blue
                                ) {
                                    selectedCategory = "All"
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .background(Color(.systemGray6).opacity(0.5))
                }
                
                // Filter Panel
                if showingFilters {
                    VStack(spacing: 16) {
                        HStack {
                            Text("Filters")
                                .font(.headline)
                            
                            Spacer()
                            
                            if isFilterActive {
                                Button("Clear All") {
                                    withAnimation {
                                        selectedType = .all
                                        selectedCategory = "All"
                                    }
                                }
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            }
                        }
                        
                        // Type Filter
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "arrow.up.arrow.down")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("Transaction Type")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                            }
                            
                            HStack(spacing: 8) {
                                ForEach(TransactionTypeFilter.allCases, id: \.self) { type in
                                    FilterButton(
                                        title: type.rawValue,
                                        isSelected: selectedType == type,
                                        color: type == .income ? .green : (type == .expense ? .red : .blue)
                                    ) {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedType = type
                                        }
                                    }
                                }
                            }
                        }
                        
                        Divider()
                        
                        // Category Filter
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "tag")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("Category")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(availableCategories, id: \.self) { category in
                                        FilterButton(
                                            title: category,
                                            isSelected: selectedCategory == category,
                                            color: .purple
                                        ) {
                                            withAnimation(.spring(response: 0.3)) {
                                                selectedCategory = category
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 0)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
                    )
                }
                
                List {
                    if filteredTransactions.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: isFilterActive ? "line.3.horizontal.decrease.circle" : "list.bullet.clipboard")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text(isFilterActive ? "No transactions match your filters" : "No transactions yet")
                                .font(.headline)
                                .foregroundColor(.gray)
                            if !isFilterActive {
                                Text("Tap + to add your first transaction")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        .listRowSeparator(.hidden)
                    } else {
                        ForEach(filteredTransactions) { transaction in
                            TransactionRow(transaction: transaction)
                                .onTapGesture {
                                    editingTransaction = transaction
                                }
                        }
                        .onDelete(perform: deleteTransactions)
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation {
                            showingFilters.toggle()
                        }
                    }) {
                        Image(systemName: isFilterActive ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .foregroundColor(isFilterActive ? .blue : .primary)
                    }
                    
                    if !store.transactions.isEmpty {
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
            .onChange(of: selectedType) { _ in
                // Reset category filter when type changes if the selected category is not available
                if !availableCategories.contains(selectedCategory) {
                    selectedCategory = "All"
                }
            }
        }
    }
    
    private func deleteTransactions(at offsets: IndexSet) {
        for index in offsets {
            store.deleteTransaction(filteredTransactions[index])
        }
    }
    
    private func exportTransactions() {
        let csvContent = generateCSVContent()
        exportFile = ExportFile(content: csvContent)
    }
    
    private func generateCSVContent() -> String {
        let header = "Date,Name,Category,Type,Amount\n"
        
        let rows = filteredTransactions.map { transaction in
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

struct FilterChip: View {
    let label: String
    let icon: String
    let color: Color
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2)
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption2)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(color.opacity(0.15))
        )
        .foregroundColor(color)
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? color : Color(.systemGray5))
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TransactionListView(store: TransactionStore())
}
