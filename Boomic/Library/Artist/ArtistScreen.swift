//
//  ArtistScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/17/24.
//

import SwiftUI
import Models

struct ArtistScreen: View {
    @Environment(\.database) private var database
    let artist: Artist
    @State private var songs: [Song] = []
    @State private var albums: [Album] = []
    
    @State var albumColumns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)

    
    var body: some View {
        ScrollView {
            HStack {
                
                Image("boomic_logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .padding(.horizontal, 110)
            }
            
            Text(artist.name)
                .font(F.title)
            
            Text("\(albums.count) albums • \(songs.count) tracks")
                .font(F.listDuration)
            
            HStack {
                Text("Songs")
                    .font(F.sectionTitle)
                
                Spacer()
            }
            .padding(.top)
            
            // Simulated List
            VStack(spacing: 0) {
                ForEach(songs) { song in
                    Divider()
                    SongListEntry(song: song)
                        .padding(7)
                }
                Divider()
            }
            
            HStack {
                Text("Albums")
                    .font(F.sectionTitle)
                
                Spacer()
            }
            .padding(.top)
            
            LazyVGrid(columns: albumColumns, alignment: .leading) {
                ForEach(albums) { album in
                    AlbumGridLink(album: album)
                }
            }
        }
        .padding(C.gridPadding)
        
        .task {
            songs = await database.getSongs(for: artist.songs)
            albums = await database.getAlbums(for: artist.albums)
        }
    }
    
    private typealias F = ViewConstants.Fonts
    private typealias C = ViewConstants

}

#Preview {
    ArtistScreen(artist: previewArtist())
        .environment(\.database, previewDatabase())
}
