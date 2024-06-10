//
//  ArtistScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/17/24.
//

import SwiftUI
import Models

private typealias C = ViewConstants
private typealias F = ViewConstants.Fonts
private typealias A = ViewConstants.Animations

struct ArtistScreen: View {
    @Environment(\.navigator) private var navigator
    @Environment(\.repository) private var repository
    @Environment(\.preferences) private var preferences
    
    let artist: Artist
    @State private var songs: [Song] = []
    @State private var albums: [Album] = []
    
    private let topSongCount = 3
    @State private var showAllSongs = false
    
    @State private var predicate: String = ""
    private var primaryOnly: Bool { preferences.localSearchOnlyPrimary }

    var body: some View {
        @Bindable var nav = navigator
        
        ScrollView {
            LazyVStack {
                if !nav.isSearchFocused {
                    MediaArtView(artist.art)
                        .clipShape(Circle())
                        .padding(.horizontal, C.artistScreenHeaderPadding)
                    
                    Text(artist.name)
                        .font(F.title)
                        .multilineTextAlignment(.center)
                    
                    Text("\(albums.count) albums • \(songs.count) tracks")
                        .font(F.listDuration)
                }
                
                HStack {
                    Text("Top Songs")
                        .font(F.sectionTitle)
                    
                    Spacer()
                }
                .padding(.top)
                
                LazyVStack(spacing: 0) {
                    ForEach(songs.search(predicate, primaryOnly: primaryOnly).prefix((showAllSongs || nav.isSearchFocused) ? songs.count : topSongCount)) { song in
                        Divider()
                        SongListButton(song: song, context: songs, queueName: artist.name)
                    }
                    Divider()
                    
                    if !nav.isSearchFocused && topSongCount < songs.count {
                        Button {
                            withAnimation(A.artistScreenShowAllSongs) { showAllSongs.toggle() }
                        } label: {
                            ZStack {
                                Color(.clear)
                                Text(showAllSongs ? "Show Less" : "Show All")
                            }
                            .frame(height: C.smallAlbumFrame + 5)
                        }
                    }
                    
                    Divider()
                }
                
                AlbumGrid(
                    key: Preferences.GridKeys.artistAlbums
                    , albums: albums.search(predicate, primaryOnly: primaryOnly)
                    , title: "Albums"
                    , titleFont: F.sectionTitle
                )
                .padding(.top)
            }
            .padding(C.gridPadding)
        }
        
        .searchable(text: $predicate, isPresented: $nav.isSearchFocused)
        
        .task {
            songs = await repository.getSongs(for: artist.songs)
            albums = await repository.getAlbums(for: artist.albums)
        }
    }
}

#Preview {
    ArtistScreen(artist: PreviewMocks.shared.previewArtist())
        .environment(\.repository, PreviewMocks.shared.previewRepository())
}
