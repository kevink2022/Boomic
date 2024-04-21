//
//  SongMenu.swift
//  Boomic
//
//  Created by Kevin Kelly on 4/19/24.
//

import SwiftUI
import Models

struct SongMenu: View {
    @Environment(\.player) private var player
    let song: Song
    
    var body: some View {
        Button {
            player.addNext(song)
        } label: {
            Label("Play Next", systemImage: "text.line.first.and.arrowtriangle.forward")
        }
        
        Button {
            player.addToEnd(song)
        } label: {
            Label("Play Last", systemImage: "text.line.last.and.arrowtriangle.forward")
        }
        
        Divider()
        
        Menu {
            Button {
                
            } label: {
                Label("Rate Song", systemImage: "star")
            }
            
            Button {
                
            } label: {
                Label("Add to Playlist", systemImage: "text.append")
            }
        } label: {
            Label("Edit Song", systemImage: "pencil.circle")
        }
        
        Divider()
        
        SongGoToMenu(song: song)
    }
}

#Preview {
    SongMenu(song: previewSong())
}
