//
//  AlbumListEntry.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/16/24.
//

import SwiftUI
import Models
import DatabaseMocks

struct AlbumListEntry: View {
    let album: Album
    
    var body: some View {
        VStack(alignment: .leading) {
            Image("boomic_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
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
        .foregroundColor(.primary)
    }
    
    typealias F = ViewConstants.Fonts
    typealias C = ViewConstants
}

#Preview {
    AllAlbumsScreen()
        .environment(\.database, GirlsApartmentDatabase())
}


