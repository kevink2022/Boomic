//
//  LibraryScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/16/24.
//

import SwiftUI


struct LibraryScreen: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    AllSongsScreen()
                } label: {
                    Text("Songs")
                }
                NavigationLink {
                    AllAlbumsScreen()
                } label: {
                    Text("Albums")
                }
                NavigationLink {
                    AllArtistsScreen()
                } label: {
                    Text("Artists")
                }
            }
        }
    }
}

#Preview {
    LibraryScreen()
        .environment(\.database, previewDatabase())
}
