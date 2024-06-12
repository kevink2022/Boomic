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
            VStack {
                if !nav.isSearchFocused {
                    VStack {
                        HStack {
                            Spacer(minLength: C.albumScreenSpacers)
                            
                            MediaArtView(album.art, cornerRadius: C.albumCornerRadius)
                            
                            Spacer(minLength: C.albumScreenSpacers)
                        }
                        
                        Text(album.title)
                            .font(F.title)
                            .multilineTextAlignment(.center)
                        
                        Text(album.artistName ?? "Unknown Artist")
                            .font(F.subtitle)
                            .multilineTextAlignment(.center)
                        
                        Text("\(songs.count) tracks • \(songs.reduce(TimeInterval(), {$0 + $1.duration}).formatted)")
                            .font(F.listDuration)
                        
                        HStack {
                            LargeButton {
                                if let song = songs.first {
                                    player.setSong(song, context: songs, queueName: album.title)
                                    if player.queueOrder == .shuffle { player.toggleShuffle() }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: SI.play)
                                    Text("Play")
                                }
                            }
                            
                            LargeButton {
                                if let song = songs.randomElement() {
                                    player.setSong(song, context: songs, queueName: album.title)
                                    if player.queueOrder == .inOrder { player.toggleShuffle() }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: SI.shuffle)
                                    Text("Shuffle")
                                }
                            }
                        }
                        .frame(height: C.buttonHeight)
                        .padding(.vertical)
                    }
                    .padding(C.gridPadding)
                }
                
                SongGrid(
                    songs: songs.search(predicate, primaryOnly: primaryOnly)
                    , key: nil
                    , config: .songAlbumStandard
                    , header: .buttonsHidden
                    , title: "Songs"
                    , titleFont: F.sectionTitle
                    , queueName: album.title
                    , showTrackNumber: true
                )
                
                ArtistGrid(
                    artists: artists.search(predicate, primaryOnly: primaryOnly)
                    , key: Preferences.GridKeys.albumArtists
                    , header: .standard
                    , title: "Artists"
                    , titleFont: F.sectionTitle
                )
                .padding(.top)
            }
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


