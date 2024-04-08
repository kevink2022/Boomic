//
//  SongListButton.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/31/24.
//

import SwiftUI
import Models

struct SongListButton: View {
    @Environment(\.player) private var player
    let song: Song
    let context: [Song]?

    let showAlbumArt: Bool
    let showArtist: Bool
    let showTrackNumber: Bool
    
    init(
        song: Song
        , context: [Song]? = nil
        , showAlbumArt: Bool = true
        , showArtist: Bool = true
        , showTrackNumber: Bool = false
    ) {
        self.song = song
        self.context = context
        self.showAlbumArt = showAlbumArt
        self.showArtist = showArtist
        self.showTrackNumber = showTrackNumber
    }
    
    var body: some View {
        Button {
            player.setSong(song, context: context)
        } label: {
            SongListEntry(
                song: song
                , showAlbumArt: showAlbumArt
                , showArtist: showArtist
                , showTrackNumber: showTrackNumber
            )
        }
        .foregroundStyle(.primary)
    }
}

#Preview {
    SongListButton(song: previewSong())
        .environment(\.player, previewPlayer())
}
