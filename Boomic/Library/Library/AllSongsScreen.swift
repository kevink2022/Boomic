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
    @State private var predicate: String = ""
    
    let filter: ((Song) -> Bool)?
    
    init(filter: ((Song) -> Bool)? = nil) {
        self.filter = filter
    }
    
    var body: some View {
        ScrollView {
            HStack {
                Text("Songs")
                    .font(F.screenTitle)
                    .padding(.horizontal, C.gridPadding)
 
                Spacer()
            }
            
            LazyVStack(spacing: 0) {
                ForEach(songs.search(predicate)) { song in
                    Divider()
                    SongListButton(song: song, context: songs, queueName: "All Songs")
                }
                Divider()
            }
        }
        
        .searchable(text: $predicate)
        
        .task {
            if let filter = filter {
                songs = repository.getSongs(for: nil).filter(filter)
            } else {
                songs = repository.getSongs(for: nil)
            }
        }
    }
}

#Preview {
    AllSongsScreen()
        .environment(\.repository, PreviewMocks.shared.previewRepository())
}
