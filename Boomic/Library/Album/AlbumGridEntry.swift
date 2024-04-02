//
//  AlbumGridEntry.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/16/24.
//

import SwiftUI
import Models
import DatabaseMocks

struct AlbumGridEntry: View {
    let album: Album
    
    var body: some View {
        VStack(alignment: .leading) {
            MediaArtView(album.art)
                .clipShape(RoundedRectangle(cornerSize: CGSize(
                    width: C.albumCornerRadius,
                    height: C.albumCornerRadius
                )))
            
            Text(album.title)
                .font(F.listTitle)
                .lineLimit(1)
            
            Text(album.artistName ?? "Unknown Artist")
                .font(F.listSubtitle)
                .lineLimit(1)
        }
        .foregroundStyle(.primary)
    }
    
    typealias F = ViewConstants.Fonts
    typealias C = ViewConstants
}

#Preview {
    AlbumGridEntry(album: previewAlbum())
}


