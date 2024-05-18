//
//  SettingsScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/30/24.
//

import SwiftUI

struct SettingsScreen: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    TransactionsList()
                } label: {
                    Text("Library Transactions")
                }
            }
        }
        

    }
}

#Preview {
    SettingsScreen()
}
