//
//  QueueControls.swift
//  Boomic
//
//  Created by Kevin Kelly on 4/13/24.
//

import SwiftUI

struct QueueControls: View {
    @Environment(\.player) private var player
    
    var body: some View {
        HStack {
            Spacer()
            
            Button {
                player.toggleShuffle()
            } label: {
                switch player.queueOrder {
                case .inOrder: Image(systemName: "arrow.forward.to.line")
                case .shuffle: Image(systemName: "shuffle")
                }
            }
            .font(F.title)
            
            Spacer()
            
            Button {
                player.toggleRepeatState()
            } label: {
                switch player.repeatState {
                case .noRepeat: Image(systemName: "arrow.right")
                case .repeatQueue: Image(systemName: "repeat")
                case .repeatSong: Image(systemName: "repeat.1")
                case .oneSong: Image(systemName: "1.circle")
                }
            }
            .font(F.title)
            
            Spacer()
            
            Button {
                player.togglePlayPause()
            } label: {
                Image(systemName: "list.bullet")
            }
            .font(F.title)
            
            Spacer()
            
            Button {
                player.fullscreen = false
            } label: {
                Image(systemName: "number")
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
    QueueControls()
        .environment(previewPlayerWithSong())
}
