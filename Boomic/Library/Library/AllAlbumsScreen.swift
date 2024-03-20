//
//  AllAlbumsScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/16/24.
//

import SwiftUI
import Models
import Database

struct AllAlbumsScreen: View {
    @Environment(\.database) private var database
    @State private var albums: [Album] = []
    @State var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        ScrollView {
            DynamicGrid(title: "Albums", titleFont: F.screenTitle) {
                ForEach(albums) { album in
                    AlbumGridLink(album: album)
                }
            }
        }
        .padding(C.gridPadding)
        
        .task {
            albums = await database.getAlbums(for: nil)
        }
    }
    
    typealias C = ViewConstants
    typealias F = ViewConstants.Fonts
}

#Preview {
    AllAlbumsScreen()
        .environment(\.database, previewDatabase())
}


