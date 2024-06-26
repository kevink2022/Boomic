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
            ScrollView {
                GridList(
                    key: Preferences.GridKeys.library
                    , title: "Library"
                    , titleFont: F.screenTitle
                    , hasSubLabels: false
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
                            
                        case .topRated:
                            GridListEntry(
                                label: "Top Rated"
                                , action: { navigator.library.navigateTo(LibraryNavigation.topRated) }
                                , icon: { LibraryGridEntry(imageName: SI.unrated) }
                            )
                            
                        case .taglists:
                            GridListEntry(
                                label: "Taglists"
                                , action: { navigator.library.navigateTo(LibraryNavigation.taglists) }
                                , icon: { LibraryGridEntry(imageName: SI.tag) }
                            )                        
                        }
                    })
                )
            }
            
            .navigationDestination(for: LibraryNavigation.self) { menu in
                switch menu {
                case .songs: AllSongsScreen()
                case .albums: AllAlbumsScreen()
                case .artists: AllArtistsScreen()
                case .topRated: AllSongsScreen(filter: {
                    guard let rating = $0.rating else { return false }
                    return rating > 0
                })
                case .taglists: AllTaglistsScreen()
                }
            }
            .navigationDestination(for: MiscLibraryNavigation.self) { destination in
                switch destination {
                case .newTaglist: TaglistScreen(taglist: nil)
                }
            }
            .navigationDestination(for: Album.self) { album in
                AlbumScreen(album: album)
            }
            .navigationDestination(for: Artist.self) { artist in
                ArtistScreen(artist: artist)
            }
            .navigationDestination(for: Taglist.self) { taglist in
                TaglistScreen(taglist: taglist)
            }
        }
    }
}

#Preview {
    LibraryScreen()
        .environment(\.repository, PreviewMocks.shared.previewRepository())
        .environment(\.navigator, Navigator())
}
