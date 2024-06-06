//
//  ArtistScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/17/24.
//

import SwiftUI
import Models

private typealias F = ViewConstants.Fonts
private typealias C = ViewConstants
private typealias A = ViewConstants.Animations

struct ArtistScreen: View {
    @Environment(\.navigator) private var navigator
    @Environment(\.repository) private var repository
    let artist: Artist
    @State private var songs: [Song] = []
    @State private var albums: [Album] = []
    
    private let topSongCount = 3
    @State private var showAllSongs = false
    
    @State var albumColumns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)

    
    var body: some View {
        ScrollView {
            LazyVStack {
                MediaArtView(artist.art)
                    .clipShape(Circle())
                    .padding(.horizontal, C.artistScreenHeaderPadding)
                
                Text(artist.name)
                    .font(F.title)
                    .multilineTextAlignment(.center)
                
                Text("\(albums.count) albums • \(songs.count) tracks")
                    .font(F.listDuration)
                
                HStack {
                    Text("Top Songs")
                        .font(F.sectionTitle)
                    
                    Spacer()
                }
                .padding(.top)
                
                LazyVStack(spacing: 0) {
                    ForEach(songs.prefix(showAllSongs ? songs.count : topSongCount)) { song in
                        Divider()
                        SongListButton(song: song, context: songs, queueName: artist.name)
                    }
                    Divider()
                    
                    if topSongCount < songs.count {
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
                
                GridList(
                    title: "Albums"
                    , key: Preferences.GridKeys.artistAlbums
                    , titleFont: F.screenTitle
                    , entries: albums.map({ album in
                        GridListEntry(
                            label: album.title
                            , subLabel: album.artistName ?? "Unknown Artist"
                            , action: { navigator.library.navigateTo(album) }
                            , icon: {
                                MediaArtView(album.art, cornerRadius: C.albumCornerRadius)
                            }
                        )
                    })
                )
                .padding(.top)
            }
            .padding(C.gridPadding)
        }
        
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
