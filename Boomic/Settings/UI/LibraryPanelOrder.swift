//
//  LibraryPanelOrder.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/4/24.
//

import SwiftUI

private typealias SI = ViewConstants.SystemImages

struct LibraryPanelOrder: View {
    @Environment(\.preferences) private var preferences
    
    var body: some View {
        @Bindable var preferences = preferences
        
        Text("Rearrange the list to order the buttons on the library home screen.")
        
        List($preferences.libraryOrder, id: \.self, editActions: .move) { $libraryButton in
            HStack {
                switch libraryButton {
                case .songs:
                    Image(systemName: SI.songs)
                    Text("Songs")
                case .albums:
                    Image(systemName: SI.album)
                    Text("Albums")
                case .artists:
                    Image(systemName: SI.artist)
                    Text("Artists")
                case .topRated:
                    Image(systemName: SI.unrated)
                    Text("Top Rated")
                case .taglists:
                    Image(systemName: SI.tag)
                    Text("Taglists")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        LibraryPanelOrder()
    }
}
