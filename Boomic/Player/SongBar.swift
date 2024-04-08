//
//  SongBar.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/30/24.
//

import SwiftUI
import Models

struct SongBar: View {
    @Environment(\.player) private var player
    
    var body: some View {
        HStack {
            MediaArtView(player.art)
                .clipShape(RoundedRectangle(cornerSize: CGSize(
                    width: C.smallAlbumCornerRadius,
                    height: C.smallAlbumCornerRadius
                )))
                .frame(height: C.smallAlbumFrame)
            
            VStack(alignment: .leading) {
                Text(player.song?.label ?? "No Song")
                    .font(F.body)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button {
                player.togglePlayPause()
            } label: {
                Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
            }
        }
        
    }
    
    private typealias C = ViewConstants
    private typealias F = ViewConstants.Fonts
}

#Preview {
    SongBar()
        .environment(\.player, previewPlayer())
}
