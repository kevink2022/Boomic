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
                MediaArtView(player.art)
                    .clipShape(RoundedRectangle(cornerSize: CGSize(
                        width: C.albumCornerRadius,
                        height: C.albumCornerRadius
                    )))
                
                
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
                    .padding(.bottom, C.gridPadding)
                    
                    TimeSlider()
                        .padding(.vertical, C.gridPadding)
                    
                    Spacer()
                    
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
                    
                    Spacer()
                    
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
                    .padding(.vertical, C.gridPadding)
                    .foregroundStyle(.primary)
                }
                .padding(.horizontal, C.gridPadding)
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
