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
    @Environment(\.repository) private var repository
    let album: Album
    @State private var songs: [Song] = []
    @State private var artists: [Artist] = []
    
    var body: some View {
        ScrollView {
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
                        
                    } label: {
                        HStack {
                            Image(systemName: SI.play)
                            Text("Play")
                        }
                    }
                    
                    LargeButton {
                        
                    } label: {
                        HStack {
                            Image(systemName: SI.shuffle)
                            Text("Shuffle")
                        }
                    }
                }
                .frame(height: C.buttonHeight)
                .padding(.vertical)
                
                HStack {
                    Text("Songs")
                        .font(F.sectionTitle)
                    
                    Spacer()
                }
                
                LazyVStack(spacing: 0) {
                    ForEach(songs) { song in
                        Divider()
                        
                        SongListButton(song: song, context: songs, queueName: album.title, showAlbumArt: false, showTrackNumber: true)
                            .padding(C.songListEntryPadding)
                    }
                    Divider()
                }
                
                HStack {
                    Text("Artists")
                        .font(F.sectionTitle)
                    
                    Spacer()
                }
                .padding(.top)
            }
            .padding(C.gridPadding)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(artists) { artist in
                        ArtistGridLink(artist: artist)
                    }
                    .frame(width: C.artistHorizontalListEntryWidth)
                }
                .frame(height: C.artistHorizontalListEntryHeight)
                .padding(C.gridPadding)
            }
        }
        
        .task {
            songs = await repository.getSongs(for: album.songs)
            artists = await repository.getArtists(for: album.artists)
        }
    }
}

#Preview {
    AlbumScreen(album: previewAlbum())
        .environment(\.repository, previewRepository())
}


