//
//  ArtistGridEntry.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/17/24.
//

import SwiftUI
import Models

struct ArtistGridEntry: View {
    let artist: Artist
    
    var body: some View {
        VStack{
            Image("boomic_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(Circle())
            
            Text(artist.name)
                .font(F.listTitle)
                .lineLimit(1)
        }
    }
    
    typealias F = ViewConstants.Fonts
    typealias C = ViewConstants
}

#Preview {
    ArtistGridEntry(artist: previewArtist())
}
