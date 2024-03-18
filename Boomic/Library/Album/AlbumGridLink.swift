//
//  AlbumGridLink.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/18/24.
//

import SwiftUI
import Models


struct AlbumGridLink: View {
    let album: Album
    
    var body: some View {
        NavigationLink {
            AlbumScreen(album: album)
        } label: {
            AlbumGridEntry(album: album)
        }
        .foregroundStyle(.primary)
    }
}

#Preview {
    AlbumGridLink(album: previewAlbum())
}
