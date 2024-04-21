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
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(.foreground)
                .opacity(0.1)
                .frame(height: 50)
            
            HStack {
                Spacer()
                
                Button {
                    player.fullscreen = false
                } label: {
                    Image(systemName: "number")
                }
                .font(F.title)
                                
                Spacer()
                
                Button {
                    player.toggleRepeatState()
                } label: {
                    switch player.repeatState {
                    case .noRepeat: Image(systemName: "arrow.forward.to.line")
                    case .repeatQueue: Image(systemName: "repeat")
                    case .repeatSong: Image(systemName: "repeat.1")
                    case .oneSong: Image(systemName: "1.circle")
                    }
                }
                .font(F.title)
                
                Spacer()
                
                Button {
                    player.toggleShuffle()
                } label: {
                    switch player.queueOrder {
                    case .inOrder: Image(systemName: "arrow.right")
                    case .shuffle: Image(systemName: "shuffle")
                    }
                }
                .font(F.title)
                
                Spacer()
                
                Button {
                    withAnimation(.snappy(duration: 0.3)) {
                        player.queueView.toggle()
                    }
                } label: {
                    Image(systemName: "list.bullet")
                }
                .font(F.title)
                
                Spacer()
            }
            .foregroundStyle(.primary)
        }
    }
    
    private typealias C = ViewConstants
    private typealias F = ViewConstants.Fonts
}

#Preview {
    QueueControls()
        .environment(previewPlayerWithSong())
}
