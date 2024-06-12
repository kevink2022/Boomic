//
//  ArtistMenu.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/11/24.
//

import SwiftUI
import Models

private typealias SI = ViewConstants.SystemImages

struct ArtistMenu: View {
    @Environment(\.repository) private var repository
    let artist: Artist
    
    var body: some View {
        Menu {
            Button {
                
            } label: {
                Label("Update Artist", systemImage: SI.unrated)
            }
            
           
            Button(role: .destructive) {
                Task{ await repository.deleteArtist(artist) }
            } label: {
                Label("Delete Artist", systemImage: SI.delete)
            }
            
            
        } label: {
            Label("Edit Artist", systemImage: SI.edit)
        }
    }
}

#Preview {
    ArtistMenu(artist: PreviewMocks.shared.previewArtist())
}
