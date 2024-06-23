//
//  AlbumScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/16/24.
//

import SwiftUI
import Models
import Database

private typealias C = ViewConstants
private typealias F = ViewConstants.Fonts
private typealias SI = ViewConstants.SystemImages

struct AlbumScreen: View {
    @Environment(\.navigator) private var navigator
    @Environment(\.player) private var player
    @Environment(\.preferences) private var preferences
    @Environment(\.repository) private var repository
    @Environment(\.selector) private var selector

    private let baseAlbum: Album
    private var album: Album { repository.album(baseAlbum) ?? baseAlbum }
    private var songs: [Song] { repository.songs(album.songs) }
    private var artists: [Artist] { repository.artists(album.artists) }
    private var exists: Bool { repository.album(baseAlbum) != nil }
    
    @State private var predicate: String = ""
    private var primaryOnly: Bool { preferences.localSearchOnlyPrimary }
    
    init(album: Album) {
        self.baseAlbum = album
    }
    
    var body: some View {
        @Bindable var nav = navigator
        
        ScrollView {
            LazyVStack {
                if !nav.isSearchFocused {
                    VStack {
                        AlbumArtHeader(art: album.art)
                        
                        Menu {
                            AlbumMenu(album: album, navigateOnSelect: true)
                        } label: {
                            VStack {
                                Text(album.title)
                                    .font(F.title)
                                    .multilineTextAlignment(.center)
                                
                                Text(album.artistName ?? "Unknown Artist")
                                    .font(F.subtitle)
                                    .multilineTextAlignment(.center)
                                
                                Text("\(songs.count) tracks • \(songs.reduce(TimeInterval(), {$0 + $1.duration}).formatted)")
                                    .font(F.listDuration)
                            }
                        }
                        .foregroundStyle(.primary)
                            
                        
                        LargePlayShuffleButtons(songs: songs, queueName: album.title)
                            .padding(.vertical)
                    }
                    .padding(C.gridPadding)
                }
                
                SongGrid(
                    songs: songs.search(predicate, primaryOnly: primaryOnly)
                    , key: nil
                    , config: .largeList
                    , header: .buttonsHidden
                    , selectable: selector.group == .songs
                    , title: "Songs"
                    , titleFont: F.sectionTitle
                    , queueName: album.title
                    , showTrackNumber: true
                )
                
                ArtistGrid(
                    artists: artists.search(predicate, primaryOnly: primaryOnly)
                    , key: Preferences.GridKeys.albumArtists
                    , header: .standard
                    , selectable: selector.group == .artists
                    , title: "Artists"
                    , titleFont: F.sectionTitle
                )
                .padding(.top)
            }
            .id(nav.isSearchFocused)
        }
        
        .searchable(text: $predicate, isPresented: $nav.isSearchFocused)
        
        .onChange(of: exists) { oldValue, newValue in
            if newValue == false { navigator.library.navigateBack() }
        }
    }
}

#Preview {
    AlbumScreen(album: PreviewMocks.shared.previewAlbum())
        .environment(\.repository, PreviewMocks.shared.previewRepository())
        .environment(\.player, PreviewMocks.shared.previewPlayer())
}


