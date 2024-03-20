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
    
    // dynamic grid
    let column: GridItem = GridItem.init(.flexible())
    @State var columnCount = 2
    @State var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    @State var showTitleButtons = false
    
    let left = "chevron.left.circle"
    let right = "chevron.right.circle"
    
    
    var body: some View {
        ScrollView {
            DynamicGrid(title: "Artists", titleFont: F.screenTitle) {
                ForEach(artists) { artist in
                    ArtistGridLink(artist: artist)
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
