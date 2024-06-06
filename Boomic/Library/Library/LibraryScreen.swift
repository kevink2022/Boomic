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
    @Environment(\.preferences) private var preferences
    
    var body: some View { 
        @Bindable var navigator = navigator
        
        NavigationStack(path: $navigator.library) {
            
            GridList(
                title: "Library"
                , key: Preferences.GridKeys.library
                , titleFont: F.screenTitle
                , entries: preferences.libraryOrder.map({ libraryButton in
                    switch libraryButton {
                    
                    case .songs:
                        GridListEntry(
                            label: "Songs"
                            , action: { navigator.library.navigateTo(LibraryNavigation.songs) }
                            , icon: { LibraryGridEntry(imageName: SI.songs) }
                        )
                    
                    case .albums:
                        GridListEntry(
                            label: "Albums"
                            , action: { navigator.library.navigateTo(LibraryNavigation.albums) }
                            , icon: { LibraryGridEntry(imageName: SI.album) }
                        )
                    
                    case .artists:
                        GridListEntry(
                            label: "Artists"
                            , action: { navigator.library.navigateTo(LibraryNavigation.artists) }
                            , icon: { LibraryGridEntry(imageName: SI.artist) }
                        )
                    }
                })
            )
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
