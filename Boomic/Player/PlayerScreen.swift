//
//  PlayerScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/31/24.
//

import SwiftUI
import Models

struct PlayerScreen: View {
    @Environment(\.player) private var player
    @Namespace private var namespace
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
                .overlay {
                    PlayerArtView()
                        .blur(radius: 50)
                        .scaleEffect(3)
                        .opacity(0.2)
                }
            
            VStack {
                HStack {
                    PlayerArtView()
                        .frame(height: player.queueView ? 80 : nil)
                    
                    if player.queueView {
                        Text(player.song?.label ?? "No Song")
                            .font(F.bold)
                            .lineLimit(1)
                        
                        Spacer()
                    }
                }
                
                if player.queueView {
                    QueueList()
                } else {
                    PlayerHeader()
                }
                
                TimeSlider()
                    .padding(C.gridPadding)
                
                Spacer()
                
                PlayerControls()
                    .padding(.vertical, 20)
                
                Spacer()
                
                QueueControls()
                    .padding(C.gridPadding)
            }
            .padding(.horizontal, C.gridPadding)
        }
        .animation(.snappy(duration: 0.2), value: player.song)
    }
    
    private typealias C = ViewConstants
    private typealias F = ViewConstants.Fonts

}

#Preview {
    PlayerScreen()
        .environment(previewPlayerWithSong())
}
