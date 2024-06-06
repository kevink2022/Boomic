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
    @State var transactions: [DataTransaction<KeySet<LibraryTransaction>>] = []
    
    var body: some View {
        Text("TransactionsList")

        List {
            ForEach(transactions) { transaction in
                NavigationLink {
                    TransactionDetailsScreen(transaction: transaction)
                } label: {
                    VStack(alignment: .leading) {
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
            
            Button(role: .destructive) {
                Task { 
                    await repository.deleteLibraryData()
                    transactions = await repository.getTransactions()
                }
            } label: {
                Text("Delete Library")
            }
            
        }
        .task {
            transactions = await repository.getTransactions()
        }
        
    }
}

#Preview {
    NavigationStack {
        TransactionsList()
    }
}
