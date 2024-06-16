//
//  PlayerHeader.swift
//  Boomic
//
//  Created by Kevin Kelly on 4/13/24.
//

import SwiftUI
import Models

private typealias C = ViewConstants
private typealias F = ViewConstants.Fonts
private typealias SI = ViewConstants.SystemImages

struct PlayerHeader: View {
    @Environment(\.player) private var player
    @Environment(\.repository) private var repository

    var body: some View {
        VStack {
            HStack {
                Text(player.song?.label ?? "No Song")
                    .font(F.title)
                    .lineLimit(1)
                
                Spacer()
            }
            .padding(.top, C.playerTitlePaddingTop)
            .padding(.bottom, C.playerTitlePaddingBottom)
            
            HStack {
                
                Menu {
                    SongGoToMenu(song: player.song ?? Song.none)
                } label: {
                    VStack(alignment: .leading) {
                        Text(player.song?.albumTitle ?? "Unknown Album")
                            .font(F.subtitle)
                            .lineLimit(1)
                        
                        Text(player.song?.artistName ?? "Unknown Artist")
                            .font(F.subtitle)
                            .lineLimit(1)
                    }
                }
                .foregroundStyle(.primary)
                
                Spacer()
                
                Button {
                    if let song = player.song {
                        let update = {
                            if song.rating == nil { return SongUpdate(song: song, rating: 1) }
                            else { return SongUpdate(song: song, erasing: [\.rating]) }
                        }()
                        Task{ await repository.updateSongs([update]) }
                    }
                } label: {
                    Image(systemName: player.song?.rating == nil ? SI.unrated : SI.rated)
                }
                .font(F.title)
                
//                Button {
//                    player.togglePlayPause()
//                } label: {
//                    Image(systemName: SI.infoCircle)
//                }
//                .font(F.title)
            }
        }
        .padding(.horizontal, C.gridPadding)
    }
}

#Preview {
    PlayerHeader()
        .environment(PreviewMocks.shared.previewPlayerWithSong())
}
