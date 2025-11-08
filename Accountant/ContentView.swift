//
//  ContentView.swift
//  Accountant
//
//  Created by Tarik Yasar on 3.11.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = TransactionStore()
    
    var body: some View {
        TabView {
            TransactionListView(store: store)
                .tabItem {
                    Label("Transactions", systemImage: "list.bullet")
                }
            
            SummaryView(store: store)
                .tabItem {
                    Label("Summary", systemImage: "chart.pie")
                }
            
            ReportsScreen(store: store)
                .tabItem {
                    Label("Reports", systemImage: "chart.bar.doc.horizontal")
                }
        }
    }
}

#Preview {
    ContentView()
}
