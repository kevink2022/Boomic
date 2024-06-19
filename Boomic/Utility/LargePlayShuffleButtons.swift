//
//  LargePlayShuffleButtons.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/18/24.
//

import SwiftUI
import Models

private typealias C = ViewConstants
private typealias SI = ViewConstants.SystemImages

struct LargePlayShuffleButtons: View {
    @Environment(\.player) private var player
    
    let songs: [Song]
    let queueName: String
    
    var body: some View {
        HStack {
            LargeButton {
                if let song = songs.first {
                    player.setSong(song, context: songs, queueName: queueName)
                    if player.queueOrder == .shuffle { player.toggleShuffle() }
                }
            } label: {
                HStack {
                    Image(systemName: SI.play)
                    Text("Play")
                }
            }
            
            LargeButton {
                if let song = songs.randomElement() {
                    player.setSong(song, context: songs, queueName: queueName)
                    if player.queueOrder == .inOrder { player.toggleShuffle() }
                }
            } label: {
                HStack {
                    Image(systemName: SI.shuffle)
                    Text("Shuffle")
                }
            }
        }
        .frame(height: C.buttonHeight)
    }
}

//#Preview {
//    LargePlayShuffleButtons()
//}
