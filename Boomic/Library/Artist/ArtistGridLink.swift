//
//  ArtistGridLink.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/18/24.
//

import SwiftUI
import Models

struct ArtistGridLink: View {
    @Environment(\.navigator) private var navigator
    let artist: Artist
    
    var body: some View {
        Button {
            navigator.library.append(artist)
        } label: {
            ArtistGridEntry(artist: artist)
        }
        .foregroundStyle(.primary)
    }
}

#Preview {
    ArtistGridLink(artist: previewArtist())
        .environment(\.navigator, previewNavigator())
}
