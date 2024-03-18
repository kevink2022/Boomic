//
//  SongListEntry.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/16/24.
//

import SwiftUI
import Models

struct SongListEntry: View {
    let song: Song
    
    
    var body: some View {
        HStack {
            
            Text(song.label)
                .font(F.body)
            
            Spacer()
            
            Text(song.duration.formatted)
                .font(F.listDuration)
            
            Button {
                
            } label: {
                Image(systemName: "ellipsis")
            }

        }
    }
    
    typealias F = ViewConstants.Fonts
}

#Preview {
    SongListEntry(song: previewSong())
}
