//
//  PlayerControls.swift
//  Boomic
//
//  Created by Kevin Kelly on 4/13/24.
//

import SwiftUI

struct PlayerControls: View {
    @Environment(\.player) private var player
    
    var body: some View {
        HStack {
            
            Spacer()
            
            Button {
                player.previous()
            } label: {
                Image(systemName: "backward.fill")
            }
            .font(F.title)
            
            Spacer()
            
            Button {
                player.togglePlayPause()
            } label: {
                Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
            }
            .font(.largeTitle)
            .scaleEffect(1.3)
            
            Spacer()
            
            Button {
                player.next()
            } label: {
                Image(systemName: "forward.fill")
            }
            .font(F.title)
            
            Spacer()
        }
        .foregroundStyle(.primary)
    }
    
    private typealias C = ViewConstants
    private typealias F = ViewConstants.Fonts
}

#Preview {
    PlayerControls()
        .environment(previewPlayerWithSong())
}
