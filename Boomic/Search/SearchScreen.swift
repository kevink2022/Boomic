//
//  SearchScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/30/24.
//

import SwiftUI
import Models

private typealias C = ViewConstants

struct SearchScreen: View {
    @Environment(\.navigator) private var navigator
    @Environment(\.player) private var player
    @Environment(\.repository) private var repository
    
    @State private var predicate: String = ""
    private var searchBlank: Bool { predicate.isEmpty }
    
    private var songs: [Song] {
        if searchBlank { return [] }
        else { return repository.songs().searchPrimary(predicate) }
    }
    
    private var albums: [Album] {
        if searchBlank { return [] }
        else { return repository.albums().searchPrimary(predicate) }
    }
    
    private var artists: [Artist] {
        if searchBlank { return [] }
        else { return repository.artists().searchPrimary(predicate) }
    }
    
    var body: some View {
        @Bindable var navigator = navigator
        
        NavigationStack(path: $navigator.search) {
            ScrollView {
                GridList(
                    key: nil
                    , config: .smallIconList
                    , header: .hidden
                    , selectable: false
                    , title: "Search"
                    , hasSubLabels: true
                    , hasListDividers: true
                    , entries:
                        albums.map({ album in
                            GridListEntry(
                                label: album.label
                                , subLabel: album.artistName
                                , action: { navigator.search.navigateTo(album) }
                                , icon: { MediaArtView(album.art, cornerRadius: C.albumCornerRadius) }
                                , menu: { AnyView(AlbumMenu(album: album)) }
                            )
                        })
                    
                    + artists.map({ artist in
                        GridListEntry(
                            label: artist.label
                            , action: { navigator.search.navigateTo(artist) }
                            , icon: { MediaArtView(artist.art, cornerRadius: 50) }
                            , menu: { AnyView(ArtistMenu(artist: artist)) }
                        )
                    })
                    
                    + songs.map({ song in
                        GridListEntry(
                            label: song.label
                            , subLabel: song.artistName
                            , action: { player.setSong(song, context: [song], queueName: "Search for: \(predicate)") }
                            , icon: { MediaArtView(song.art, cornerRadius: C.albumCornerRadius) }
                            , menu: { AnyView(SongMenu(song: song)) }
                        )
                    })
                )
            }
            .searchable(text: $predicate, isPresented: $navigator.isSearchFocused, placement: .toolbar, prompt: nil)
            
            .navigationDestination(for: Album.self) { album in
                AlbumScreen(album: album)
            }
            .navigationDestination(for: Artist.self) { artist in
                ArtistScreen(artist: artist)
            }
        }
        .environment(\.isSearchTab, true)
    }
}

#Preview {
    SearchScreen()
}
