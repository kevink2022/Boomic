//
//  SongGoToMenu.swift
//  Boomic
//
//  Created by Kevin Kelly on 4/20/24.
//

import SwiftUI
import Models

private typealias SI = ViewConstants.SystemImages

struct SongGoToMenu: View {
    @Environment(\.repository) private var repository
    @Environment(\.navigator) private var navigator
    let song: Song
    
    var body: some View {
        if song.artists.count > 0 {
            ForEach(repository.getArtists(for: song.artists)) { artist in
                Button {
                    navigator.tab = .home
                    navigator.library.append(artist)
                    navigator.closePlayer()
                } label: {
                    Label(artist.name, systemImage: SI.artist)
                }
            }
        }
        
        if song.albums.count > 0 {
            ForEach(repository.getAlbums(for: song.albums)) { album in
                Button {
                    navigator.tab = .home
                    navigator.library.append(album)
                    navigator.closePlayer()
                } label: {
                    Label(album.title, systemImage: SI.album)
                }
            }
        }
    }
}

#Preview {
    SongGoToMenu(song: PreviewMocks.shared.previewSong())
}
