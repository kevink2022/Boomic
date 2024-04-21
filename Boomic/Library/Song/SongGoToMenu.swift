//
//  SongGoToMenu.swift
//  Boomic
//
//  Created by Kevin Kelly on 4/20/24.
//

import SwiftUI
import Models

struct SongGoToMenu: View {
    @Environment(\.repository) private var repository
    let song: Song
    
    var body: some View {
        if song.artists.count > 0 {
            ForEach(repository.getArtists(for: song.artists)) { artist in
                NavigationLink {
                    ArtistScreen(artist: artist)
                } label: {
                    Label(artist.name, systemImage: "music.mic")
                }
            }
        }
        
        if song.albums.count > 0 {
            ForEach(repository.getAlbums(for: song.albums)) { album in
                NavigationLink {
                    AlbumScreen(album: album)
                } label: {
                    Label(album.title, systemImage: "opticaldisc")
                }
            }
        }
    }
}

#Preview {
    SongGoToMenu(song: previewSong())
}
