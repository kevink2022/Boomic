//
//  LibraryScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/16/24.
//

import SwiftUI
import Models

private typealias C = ViewConstants
private typealias F = ViewConstants.Fonts
private typealias SI = ViewConstants.SystemImages

struct LibraryScreen: View {
    @Environment(\.repository) private var repository
    @Environment(\.navigator) private var navigator
    
    var body: some View { 
        @Bindable var navigator = navigator
        
        NavigationStack(path: $navigator.library) {
            DynamicGrid(title: "Library", titleFont: F.screenTitle) {
                Button {
                    navigator.library.append(LibraryNavigation.songs)
                    
                } label: {
                    LibraryGridEntry(title: "Songs", imageName: SI.songs)
                }
                
                Button {
                    navigator.library.append(LibraryNavigation.albums)
                } label: {
                    LibraryGridEntry(title: "Albums", imageName: SI.album)
                }
                
                Button {
                    navigator.library.append(LibraryNavigation.artists)
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
            
            .navigationDestination(for: LibraryNavigation.self) { menu in
                switch menu {
                case .songs: AllSongsScreen()
                case .albums: AllAlbumsScreen()
                case .artists: AllArtistsScreen()
                }
            }
            .navigationDestination(for: Album.self) { album in
                AlbumScreen(album: album)
            }
            .navigationDestination(for: Artist.self) { artist in
                ArtistScreen(artist: artist)
            }
        }
    }
}

#Preview {
    LibraryScreen()
        .environment(\.repository, PreviewMocks.shared.previewRepository())
        .environment(\.navigator, Navigator())
}
