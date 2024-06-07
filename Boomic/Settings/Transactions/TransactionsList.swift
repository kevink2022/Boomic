//
//  TransactionsList.swift
//  Boomic
//
//  Created by Kevin Kelly on 4/28/24.
//

import SwiftUI
import Database

private typealias F = ViewConstants.Fonts
private typealias SI = ViewConstants.SystemImages

struct TransactionsList: View {
    @Environment(\.repository) private var repository
    @State private var transactions: [DataTransaction<LibraryTransaction>] = []
    @State private var viewOnlySignificant = true
    
    var body: some View {
        List {
            Section {
                Picker("Filter List", selection: $viewOnlySignificant) {
                    Text("Significant").tag(true)
                    Text("All").tag(false)
                }
                .pickerStyle(.segmented)
            }
            
            ForEach(
                transactions.filter { !viewOnlySignificant || $0.data.level == .significant }
            ) { transaction in
                NavigationLink {
                    TransactionAssertionsScreen(transaction: transaction)
                } label: {
                    VStack(alignment: .leading) {
                        Text(transaction.data.label)
                            .font(transaction.data.level == .significant ? F.listEntryTitle : F.body)
                        Text(transaction.timestamp.shortFormatted)
                            .opacity(0.6)
                    }
                }
                .contextMenu {
                    Button {
                        Task { 
                            await repository.rollbackTo(after: transaction)
                            await loadTransactions()
                        }
                    } label: {
                        Label("Rollback to After", systemImage: SI.afterTransaction)
                    }
                    
                    Button {
                        Task { 
                            await repository.rollbackTo(before: transaction)
                            await loadTransactions()
                        }
                    } label: {
                        Label("Rollback to Before", systemImage: SI.beforeTransaction)
                    }
                }
            }
        }
        .task {
            await loadTransactions()
        }
        .refreshable {
            await loadTransactions()
        }
    }
    
    private func loadTransactions() async {
        transactions = await repository.getTransactions()
    }
}

#Preview {
    NavigationStack {
        TransactionsList()
    }
}
