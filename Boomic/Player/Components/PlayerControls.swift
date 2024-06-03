//
//  PlayerControls.swift
//  Boomic
//
//  Created by Kevin Kelly on 4/13/24.
//

import SwiftUI

private typealias C = ViewConstants
private typealias F = ViewConstants.Fonts
private typealias SI = ViewConstants.SystemImages

struct PlayerControls: View {
    @Environment(\.player) private var player
    
    var body: some View {
        HStack {
            Spacer()
            
            Button {
                player.previous()
            } label: {
                Image(systemName: SI.backwardSkip)
            }
            .font(F.playerButton)
            
            Spacer()
            
            Button {
                player.togglePlayPause()
            } label: {
                Image(systemName: player.isPlaying ? SI.pause : SI.play)
            }
            .font(F.playbackButton)
            .scaleEffect(C.playbackButtonScaleEffect)
            
            Spacer()
            
            Button {
                player.next()
            } label: {
                Image(systemName: SI.forwardSkip)
            }
            .font(F.playerButton)
            
            Spacer()
        }
        .foregroundStyle(.primary)
    }
}

#Preview {
    PlayerControls()
        .environment(PreviewMocks.shared.previewPlayerWithSong())
}
