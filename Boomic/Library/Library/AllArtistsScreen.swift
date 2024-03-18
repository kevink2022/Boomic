//
//  AllArtistsScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/17/24.
//

import SwiftUI
import Models
import Database

struct AllArtistsScreen: View {
    @Environment(\.database) private var database
    @State private var artists: [Artist] = []
    @State var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        ScrollView {
            
            HStack {
                Text("Artists")
                    .font(F.screenTitle)
 
                Spacer()
            }

            LazyVGrid(columns: columns, alignment: .leading) {
                ForEach(artists) { artist in
                    NavigationLink {
                        ArtistScreen(artist: artist)
                    } label: {
                        ArtistGridEntry(artist: artist)
                    }
                }
            }
            
        }
        .padding(C.gridPadding)
        
        .task {
            artists = await database.getArtists(for: nil)
        }
    }
    
    typealias C = ViewConstants
    typealias F = ViewConstants.Fonts
}

#Preview {
    AllArtistsScreen()
        .environment(\.database, previewDatabase())
}
