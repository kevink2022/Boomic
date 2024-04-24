//
//  QueueControls.swift
//  Boomic
//
//  Created by Kevin Kelly on 4/13/24.
//

import SwiftUI

private typealias C = ViewConstants
private typealias F = ViewConstants.Fonts
private typealias A = ViewConstants.Animations
private typealias SI = ViewConstants.SystemImages

struct QueueControls: View {
    @Environment(\.player) private var player
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: C.queueControlsBarCornerRadius)
                .foregroundStyle(.foreground)
                .opacity(C.queueControlsBarOpacity)
                .frame(height: C.queueControlsBarHeight)
            
            HStack {
                Spacer()
                
                Button {
                    player.fullscreen = false
                } label: {
                    Image(systemName: SI.tag)
                }
                .font(F.playerButton)
                                
                Spacer()
                
                Button {
                    player.toggleRepeatState()
                } label: {
                    switch player.repeatState {
                    case .noRepeat: Image(systemName: SI.noRepeat)
                    case .repeatQueue: Image(systemName: SI.repeatQueue)
                    case .repeatSong: Image(systemName: SI.repeatSong)
                    case .oneSong: Image(systemName: SI.oneSong)
                    }
                }
                .font(F.playerButton)
                
                Spacer()
                
                Button {
                    player.toggleShuffle()
                } label: {
                    switch player.queueOrder {
                    case .inOrder: Image(systemName: SI.inOrder)
                    case .shuffle: Image(systemName: SI.shuffle)
                    }
                }
                .font(F.playerButton)
                
                Spacer()
                
                Button {
                    withAnimation(A.toggleQueue) {
                        player.queueView.toggle()
                    }
                } label: {
                    Image(systemName: SI.queue)
                }
                .font(F.playerButton)
                
                Spacer()
            }
            .foregroundStyle(.primary)
        }
    }
}

#Preview {
    QueueControls()
        .environment(previewPlayerWithSong())
}
