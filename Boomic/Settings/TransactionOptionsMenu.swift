//
//  TransactionOptionsMenu.swift
//  Boomic
//
//  Created by Kevin Kelly on 5/31/24.
//

import SwiftUI
import Database

private typealias SI = ViewConstants.SystemImages

struct TransactionOptionsMenu: View {
    @Environment(\.repository) private var repository
    let transaction: DataTransaction<KeySet<LibraryTransaction>>
    
    
    var body: some View {
        Button {
            Task { await repository.rollbackTo(after: transaction) }
        } label: {
            Label("Rollback to After", systemImage: SI.afterTransaction)
        }
        
        Button {
            Task { await repository.rollbackTo(before: transaction) }
        } label: {
            Label("Rollback to Before", systemImage: SI.beforeTransaction)
        }
    }
}

//#Preview {
//    TransactionOptionsMenu()
//}
