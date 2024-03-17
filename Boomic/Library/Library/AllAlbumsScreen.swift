//
//  AllAlbumsScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/16/24.
//

import SwiftUI
import Models
import Database
import DatabaseMocks

struct AllAlbumsScreen: View {
    @Environment(\.database) private var database
    @State private var albums: [Album] = []
    @State var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading) {
            ForEach(albums) { album in
                NavigationLink {
                    AlbumScreen(album: album)
                } label: {
                    AlbumListEntry(album: album)
                }
            }
        }
        .padding(C.gridPadding)
        
        .task {
            albums = await database.getAlbums(for: nil)
        }
    }
    
    typealias C = ViewConstants
}

#Preview {
    AllAlbumsScreen()
        .environment(\.database, GirlsApartmentDatabase())
}


