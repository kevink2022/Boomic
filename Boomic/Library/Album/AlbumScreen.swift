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
    private let baseAlbum: Album
    @State private var query = Query()
    private var album: Album { query.albums.first ?? baseAlbum }
    private var songs: [Song] { query.songs }
    private var artists: [Artist] { query.artists }
    
    init(album: Album) {
        self.baseAlbum = album
//        query.forAlbum(album)
//        repository.addQuery(query)
    }
    
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
            query.forAlbum(album)
            repository.addQuery(query)
//            songs = await repository.getSongs(for: album.songs)
//            artists = await repository.getArtists(for: album.artists)
        }
    }
}

#Preview {
    AlbumScreen(album: PreviewMocks.shared.previewAlbum())
        .environment(\.repository, PreviewMocks.shared.previewRepository())
}


