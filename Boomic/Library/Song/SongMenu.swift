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
    @Environment(\.navigator) private var navigator
    @Environment(\.player) private var player
    @Environment(\.repository) private var repository
    @Environment(\.selector) private var selector
    
    let song: Song
    
    @State private var deleteAlert = false
    
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
        
        if !selector.active {
            Button {
                selector.select(.songs)
                selector.toggleSelect(song.id, group: .songs)
            } label: {
                Label("Select Song", systemImage: SI.select)
            }
        }
        
        Divider()
        
        Menu {
            Button {
                
            } label: {
                Label("Rate Song", systemImage: SI.unrated)
            }
            
            Button {
                
            } label: {
                Label("Add to Playlist", systemImage: SI.addToPlaylist)
            }
            
            Button {
                navigator.presentSheet(SongUpdateSheet(song: song))
            } label: {
                Label("Edit Attributes", systemImage: SI.edit)
            }
            
            Button(role: .destructive) {
                Task{ await repository.deleteSong(song) }
            } label: {
                Label("Delete Song", systemImage: SI.delete)
            }

            
        } label: {
            Label("Edit Song", systemImage: SI.edit)
        }
        
        Divider()
        
        SongGoToMenu(song: song)
    }
}

#Preview {
    SongMenu(song: PreviewMocks.shared.previewSong())
}
