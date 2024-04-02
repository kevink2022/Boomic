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
            DynamicGrid(title: "Library", titleFont: F.screenTitle) {
                NavigationLink {
                    AllSongsScreen()
                } label: {
                    LibraryGridEntry(title: "Songs", imageName: "music.quarternote.3")
                }
                
                NavigationLink {
                    AllAlbumsScreen()
                } label: {
                    LibraryGridEntry(title: "Albums", imageName: "opticaldisc")
                }
                
                NavigationLink {
                    AllArtistsScreen()
                } label: {
                    LibraryGridEntry(title: "Artists", imageName: "music.mic")
                }
                
                Button {
                    Task { await repository.addSongs([]) }
                } label: {
                    LibraryGridEntry(title: "Add Songs", imageName: "plus.circle")
                }
            }
            .foregroundStyle(.primary)
            .padding(C.gridPadding)
            
        }
        
    }
    
    private typealias C = ViewConstants
    private typealias F = ViewConstants.Fonts
}

#Preview {
    LibraryScreen()
        .environment(\.repository, livePreviewRepository())
}
