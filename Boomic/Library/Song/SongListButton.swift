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
    let context: [Song]
    let queueName: String

    let showAlbumArt: Bool
    let showArtist: Bool
    let showTrackNumber: Bool
    
    init(
        song: Song
        , context: [Song]
        , queueName: String = "Queue"
        , showAlbumArt: Bool = true
        , showArtist: Bool = true
        , showTrackNumber: Bool = false
    ) {
        self.song = song
        self.context = context
        self.queueName = queueName
        self.showAlbumArt = showAlbumArt
        self.showArtist = showArtist
        self.showTrackNumber = showTrackNumber
    }
    
    var body: some View {
        Button {
            player.setSong(song, context: context, queueName: queueName)
        } label: {
            SongListEntry(
                song: song
                , showAlbumArt: showAlbumArt
                , showArtist: showArtist
                , showTrackNumber: showTrackNumber
            )
        }
        .foregroundStyle(.primary)
        .contextMenu { SongMenu(song: song) }
    }
}

#Preview {
    SongListButton(song: PreviewMocks.shared.previewSong(), context: [PreviewMocks.shared.previewSong()])
        .environment(\.player, PreviewMocks.shared.previewPlayer())
}
