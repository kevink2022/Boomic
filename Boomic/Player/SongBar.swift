//
//  SongBar.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/30/24.
//

import SwiftUI
import Models

private typealias C = ViewConstants
private typealias F = ViewConstants.Fonts

struct SongBar: View {
    @Environment(\.player) private var player
    
    var body: some View {
        HStack {
            PlayerArtView(cornerRadius: C.smallAlbumCornerRadius)
                .frame(height: C.smallAlbumFrame)
            
            VStack(alignment: .leading) {
                Text(player.song?.label ?? "No Song")
                    .font(F.bold)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button {
                player.togglePlayPause()
            } label: {
                Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                    .font(.title3)
            }
            .padding(.trailing, C.gridPadding)
        }
    }
}

#Preview {
    SongBar()
        .environment(\.player, PreviewMocks.shared.previewPlayer())
}
