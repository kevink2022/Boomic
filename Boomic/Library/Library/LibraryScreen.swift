//
//  LibraryScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/16/24.
//

import SwiftUI

private typealias C = ViewConstants
private typealias F = ViewConstants.Fonts
private typealias SI = ViewConstants.SystemImages

struct LibraryScreen: View {
    @Environment(\.repository) private var repository
    
    var body: some View {
        NavigationStack {
            DynamicGrid(title: "Library", titleFont: F.screenTitle) {
                NavigationLink {
                    AllSongsScreen()
                } label: {
                    LibraryGridEntry(title: "Songs", imageName: SI.songs)
                }
                
                NavigationLink {
                    AllAlbumsScreen()
                } label: {
                    LibraryGridEntry(title: "Albums", imageName: SI.album)
                }
                
                NavigationLink {
                    AllArtistsScreen()
                } label: {
                    LibraryGridEntry(title: "Artists", imageName: SI.artist)
                }
                
                Button {
                    Task { await repository.addSongs([]) }
                } label: {
                    LibraryGridEntry(title: "Add Songs", imageName: SI.addSongs)
                }
            }
            .foregroundStyle(.primary)
            .padding(C.gridPadding)
        }
    }
}

#Preview {
    LibraryScreen()
        .environment(\.repository, livePreviewRepository())
}
