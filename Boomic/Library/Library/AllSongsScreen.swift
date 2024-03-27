//
//  AllSongsScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/17/24.
//

import SwiftUI
import Models
import Database

struct AllSongsScreen: View {
    @Environment(\.repository) private var repository
    @State private var songs: [Song] = []
    
    var body: some View {
        ScrollView {
            
            HStack {
                Text("Songs")
                    .font(F.screenTitle)
 
                Spacer()
            }
            
            VStack(spacing: 0) {
                ForEach(songs) { song in
                    Divider()
                    SongListEntry(song: song)
                        .padding(7)
                }
                Divider()
            }
            
        }
        
        .task {
            songs = await repository.getSongs(for: nil)
        }
    }
    
    typealias C = ViewConstants
    typealias F = ViewConstants.Fonts
}

#Preview {
    AllSongsScreen()
        .environment(\.repository, previewRepository())
}
