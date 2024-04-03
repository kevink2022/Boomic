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
        VStack {
            MediaArtView(player.song?.art)
                .clipShape(RoundedRectangle(cornerSize: CGSize(
                    width: C.albumCornerRadius,
                    height: C.albumCornerRadius
                )))
            
            Spacer()
            
            VStack {
                Spacer()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(player.song?.label ?? "No Song")
                            .font(F.title)
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
                                
                VStack {
                    
                    RoundedRectangle(cornerSize: CGSize(width: 5, height: 5))
                        .frame(height: 10)
                    
                    HStack {
                        Text("0:00")
                            .font(F.trackNumber)
                        
                        Spacer()
                        
                        Text("0:00")
                            .font(F.trackNumber)
                    }
                }
                
                Spacer()
                
                HStack {
                    
                    Spacer()
                    
                    Button {
                        player.togglePlayPause()
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
                    
                    Spacer()
                    
                    Button {
                        player.togglePlayPause()
                    } label: {
                        Image(systemName: "forward.fill")
                    }
                    .font(F.title)
                    
                    Spacer()
                }
                
                Spacer()
                
                HStack {
                    
                    Spacer()
                    
                    Button {
                        player.togglePlayPause()
                    } label: {
                        Image(systemName: "shuffle")
                    }
                    .font(F.title)
                    
                    Spacer()
                    
                    Button {
                        player.togglePlayPause()
                    } label: {
                        Image(systemName: "repeat")
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
                
            }
            .padding(C.gridPadding)
        }
        .padding(.horizontal, C.gridPadding)
    }
    
    private typealias C = ViewConstants
    private typealias F = ViewConstants.Fonts
}

#Preview {
    PlayerScreen()
        .environment(previewPlayerWithSong())
}