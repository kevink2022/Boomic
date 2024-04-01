//
//  LibraryScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/16/24.
//

import SwiftUI


struct LibraryScreen: View {
    
    @Environment(\.repository) private var repository
    
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
                Button {
                    Task { await repository.addSongs([]) }
                } label: {
                    Text("Add Songs")
                }
            }
            .listStyle(.inset)
        }
    }
}

#Preview {
    LibraryScreen()
        .environment(\.repository, livePreviewRepository())
}
