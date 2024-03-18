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
        List {
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
            }
            
            ForEach(songs) { song in
                HStack {
                    Text("\(song.trackNumber.map { String($0) } ?? "")")
                        .font(F.trackNumber)
                        .frame(minWidth: 20, alignment: .leading)

                    SongListEntry(song: song)
                 }
            }
            
            HStack {
                Text("Artists")
                    .font(F.sectionTitle)
                
                Spacer()
            }
            .padding(.top)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(artists) { artist in
                        NavigationLink {
                            ArtistScreen(artist: artist)
                        } label: {
                            ArtistGridEntry(artist: artist)

                        }
                    }
                    .frame(width: 120)
                }
            }
            .frame(height: 150)
            .padding(.horizontal, -15)
        }
        .listStyle(.inset)
        
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


