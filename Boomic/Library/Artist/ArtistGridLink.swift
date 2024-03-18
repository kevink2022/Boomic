//
//  ArtistGridLink.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/18/24.
//

import SwiftUI
import Models

struct ArtistGridLink: View {
    let artist: Artist
    
    var body: some View {
        NavigationLink {
            ArtistScreen(artist: artist)
        } label: {
            ArtistGridEntry(artist: artist)
        }
        .foregroundStyle(.primary)
    }
}

#Preview {
    ArtistGridLink(artist: previewArtist())
}
