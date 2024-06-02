//
//  TransactionsList.swift
//  Boomic
//
//  Created by Kevin Kelly on 4/28/24.
//

import SwiftUI
import Database

private typealias F = ViewConstants.Fonts

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
                    TransactionOptionsMenu(transaction: transaction)
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
