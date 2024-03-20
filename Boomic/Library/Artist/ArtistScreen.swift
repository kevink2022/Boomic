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
    
    private let topSongCount = 3
    @State private var showAllSongs = false
    
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
                Text("Top Songs")
                    .font(F.sectionTitle)
                
                Spacer()
            }
            .padding(.top)
            
            VStack(spacing: 0) {
                ForEach(songs.prefix(showAllSongs ? songs.count : topSongCount)) { song in
                    Divider()
                    SongListEntry(song: song)
                        .padding(7)
                }
                Divider()
                
                if topSongCount < songs.count {
                    Button {
                        withAnimation(.easeOut(duration: 0.2)) { showAllSongs.toggle() }
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
            
            DynamicGrid(title: "Albums") {
                ForEach(albums) { album in
                    AlbumGridLink(album: album)
                }
            }
            .padding(.top)
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
