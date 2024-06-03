//
//  AllSongsScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/17/24.
//

import SwiftUI
import Models

private typealias C = ViewConstants
private typealias F = ViewConstants.Fonts

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
            
            LazyVStack(spacing: 0) {
                ForEach(songs) { song in
                    Divider()
                    SongListButton(song: song, context: songs, queueName: "All Songs")
                        .padding(C.songListEntryPadding)
                }
                Divider()
            }
            
        }
        
        .task {
            songs = await repository.getSongs(for: nil)
        }
    }
}

#Preview {
    AllSongsScreen()
        .environment(\.repository, PreviewMocks.shared.previewRepository())
}
