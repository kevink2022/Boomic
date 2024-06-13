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
    @Environment(\.selector) private var selector

    let artist: Artist
    
    var body: some View {
        if !selector.active {
            Button {
                selector.select(.artists)
                selector.toggleSelect(artist.id, group: .artists)
            } label: {
                Label("Select Artist", systemImage: SI.select)
            }
        }
        
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
