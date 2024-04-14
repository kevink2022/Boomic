//
//  PlayerHeader.swift
//  Boomic
//
//  Created by Kevin Kelly on 4/13/24.
//

import SwiftUI

struct PlayerHeader: View {
    @Environment(\.player) private var player
    
    var body: some View {
        PlayerArtView()
        
        VStack {
            HStack {
                Text(player.song?.label ?? "No Song")
                    .font(F.title)
                    .lineLimit(1)
                
                Spacer()
            }
            .padding(.top, 20)
            .padding(.bottom, 10)
            
            HStack {
                
                VStack(alignment: .leading) {
                    Text(player.song?.albumTitle ?? "Unknown Album")
                        .font(F.subtitle)
                        .lineLimit(1)
                    
                    Text(player.song?.artistName ?? "Unknown Artist")
                        .font(F.subtitle)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Button {
                    player.togglePlayPause()
                } label: {
                    Image(systemName: "star.circle")
                }
                .font(F.title)
                
                Button {
                    player.togglePlayPause()
                } label: {
                    Image(systemName: "info.circle")
                }
                .font(F.title)
            }
        }
        .padding(.horizontal, C.gridPadding)
    }
    
    private typealias C = ViewConstants
    private typealias F = ViewConstants.Fonts
}

#Preview {
    PlayerHeader()
        .environment(previewPlayerWithSong())
}
