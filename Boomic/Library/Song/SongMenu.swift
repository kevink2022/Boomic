//
//  SongMenu.swift
//  Boomic
//
//  Created by Kevin Kelly on 4/19/24.
//

import SwiftUI
import Models

private typealias SI = ViewConstants.SystemImages

struct SongMenu: View {
    @Environment(\.player) private var player
    let song: Song
    
    var body: some View {
        Button {
            player.addNext(song)
        } label: {
            Label("Play Next", systemImage: SI.topOfQueue)
        }
        
        Button {
            player.addToEnd(song)
        } label: {
            Label("Play Last", systemImage: SI.bottomOfQueue)
        }
        
        Divider()
        
        Menu {
            Button {
                
            } label: {
                Label("Rate Song", systemImage: SI.rate)
            }
            
            Button {
                
            } label: {
                Label("Add to Playlist", systemImage: SI.addToPlaylist)
            }
        } label: {
            Label("Edit Song", systemImage: SI.edit)
        }
        
        Divider()
        
        SongGoToMenu(song: song)
    }
}

#Preview {
    SongMenu(song: previewSong())
}
