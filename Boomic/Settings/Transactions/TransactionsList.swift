//
//  TransactionsList.swift
//  Boomic
//
//  Created by Kevin Kelly on 4/28/24.
//

import SwiftUI
import Database
import Storage

private typealias F = ViewConstants.Fonts
private typealias SI = ViewConstants.SystemImages

struct TransactionsList: View {
    @Environment(\.repository) private var repository
    
    @State private var transactions: [DataTransaction<LibraryTransaction>] = []
    @State private var viewOnlySignificant = true
    @State private var rollbackStatus: String = ""
    private var rollbackInProgess: Bool {
        repository.statusActive(for: .rollback)
    }
    
    var body: some View {
        List {
            Section {
                Picker("Filter List", selection: $viewOnlySignificant) {
                    Text("Significant").tag(true)
                    Text("All").tag(false)
                }
                .pickerStyle(.segmented)
            } header: {
                Text("Detail Level")
            } footer: {
                if rollbackInProgess {
                    HStack(spacing: 10) {
                        ProgressView()
                        Text(rollbackStatus)
                    }
                }
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
                            transactions = await repository.getTransactions()
                        }
                    } label: {
                        Label("Rollback to After", systemImage: SI.afterTransaction)
                    }
                    
                    Button {
                        Task { 
                            await repository.rollbackTo(before: transaction)
                            transactions = await repository.getTransactions()
                        }
                    } label: {
                        Label("Rollback to Before", systemImage: SI.beforeTransaction)
                    }
                }
            }
        }
        .task {
            transactions = await repository.getTransactions()
        }
        .refreshable {
            transactions = await repository.getTransactions()
        }
        
        .onChange(of: repository.status) {
            if repository.status.key == .rollback {
                rollbackStatus = repository.status.message
            }
        }
    }
    
//    private func loadTransactions() async {
//        transactions = await repository.getTransactions()
//    }
}

#Preview {
    NavigationStack {
        TransactionsList()
    }
}
