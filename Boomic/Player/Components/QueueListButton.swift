//
//  QueueListButton.swift
//  Boomic
//
//  Created by Kevin Kelly on 4/15/24.
//

import SwiftUI
import Models


struct QueueListButton: View {
    @Environment(\.player) private var player
    let song: Song
    let forwardQueueIndex: Int
    
    var body: some View {
        Button {
            player.setSong(song, forwardQueueIndex: forwardQueueIndex)
        } label: {
            SongListEntry(song: song)
        }
        .foregroundStyle(.primary)
    }
}

#Preview {
    QueueListButton(song: previewSong(), forwardQueueIndex: 1)
}
