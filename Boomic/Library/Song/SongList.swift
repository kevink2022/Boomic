//
//  SongList.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/16/24.
//

import SwiftUI
import Models

struct SongList: View {
    let songs: [Song]
    
    
    var body: some View {
        ForEach(songs) { song in
            HStack {
                if let trackNumber = song.trackNumber {
                    Text("\(trackNumber)")
                }
                Text(song.label)
            }
            
        }
    }
}

//#Preview {
//    SongList()
//}
