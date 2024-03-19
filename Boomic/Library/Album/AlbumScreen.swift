//
//  AlbumScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/16/24.
//

import SwiftUI
import Models
import Database

struct AlbumScreen: View {
    @Environment(\.database) private var database
    let album: Album
    @State private var songs: [Song] = []
    @State private var artists: [Artist] = []
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Spacer(minLength: 70)
                    
                    Image("boomic_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerSize: CGSize(
                            width: C.albumCornerRadius,
                            height: C.albumCornerRadius
                        )))
                    
                    Spacer(minLength: 70)
                }
                
                Text(album.title)
                    .font(F.title)
                
                Text(album.artistName ?? "Unknown Artist")
                    .font(F.subtitle)
                
                Text("\(songs.count) tracks • \(songs.reduce(TimeInterval(), {$0 + $1.duration}).formatted)")
                    .font(F.listDuration)
                
                HStack {
                    LargeButton {
                        
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Play")
                        }
                    }
                    
                    LargeButton {
                        
                    } label: {
                        HStack {
                            Image(systemName: "shuffle")
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
                
                VStack(spacing: 0) {
                    ForEach(songs) { song in
                        Divider()
                        HStack {
                            Text("\(song.trackNumber.map { String($0) } ?? "")")
                                .font(F.trackNumber)
                                .frame(minWidth: 22, alignment: .leading)

                            SongListEntry(song: song, showAlbumArt: false)
                         }
                        .padding(7)
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
                    .frame(width: 120)
                }
                .frame(height: 150)
                .padding(C.gridPadding)
            }
        }
        
        .task {
            songs = await database.getSongs(for: album.songs)
            artists = await database.getArtists(for: album.artists)
        }
    }
    
    private typealias C = ViewConstants
    private typealias F = ViewConstants.Fonts
}

#Preview {
    AlbumScreen(album: previewAlbum())
        .environment(\.database, previewDatabase())
}


