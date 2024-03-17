//
//  LibraryScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/16/24.
//

import SwiftUI
import DatabaseMocks


struct LibraryScreen: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    AllAlbumsScreen()
                } label: {
                    Text("Albums")
                }
            }
        }
    }
}

#Preview {
    LibraryScreen()
        .environment(\.database, GirlsApartmentDatabase())
}
