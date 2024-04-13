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
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
                .overlay {
                    MediaArtView(player.art, aspectRatio: .fill)
                        .blur(radius: 50)
                        .scaleEffect(2)
                        .opacity(0.2)
                }
            
            VStack {
                PlayerHeader()
                
                TimeSlider()
                    .padding(C.gridPadding)
                
                Spacer()
                
                PlayerControls()
                
                Spacer()
                
                QueueControls()
                    .padding(C.gridPadding)
            }
            .padding(.horizontal, C.gridPadding)
        }
    }
    
    private typealias C = ViewConstants
    private typealias F = ViewConstants.Fonts
}

#Preview {
    PlayerScreen()
        .environment(previewPlayerWithSong())
}
