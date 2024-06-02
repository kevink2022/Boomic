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
    @Environment(\.repository) private var repository
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
            
            Button(role: .destructive) {
                //deleteAlert = true
                Task{ await repository.deleteSong(song) }
            } label: {
                Label("Delete Song", systemImage: SI.delete)
            }
            .alert(isPresented: $deleteAlert) {
                Alert(
                    title: Text("Delete Song"),
                    message: Text("Are you sure you want to delete this song? (Song file will not be deleted)"),
                    primaryButton: .destructive(Text("Delete")) { Task{ await repository.deleteSong(song) } },
                    secondaryButton: .cancel()
                )
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
