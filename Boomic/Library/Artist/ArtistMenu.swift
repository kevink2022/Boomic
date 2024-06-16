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
    @Environment(\.navigator) private var navigator
    @Environment(\.repository) private var repository
    @Environment(\.selector) private var selector

    let artist: Artist
    let navigateOnSelect: Bool
    
    init(
        artist: Artist
        , navigateOnSelect: Bool = false
    ) {
        self.artist = artist
        self.navigateOnSelect = navigateOnSelect
    }
    
    var body: some View {
        if !selector.active {
            Button {
                selector.selectGroup(.artists)
                selector.toggleSelect(artist.id, group: .artists)
                if navigateOnSelect {
                    navigator.library.navigateTo(LibraryNavigation.artists, clearingPath: true)
                }
            } label: {
                Label("Select Artist", systemImage: SI.select)
            }
        }
        
        Menu {
            Button {
                navigator.presentSheet(ArtistUpdateSheet(artists: [artist]))
            } label: {
                Label("Update Artist", systemImage: SI.unrated)
            }
            
           
            Button(role: .destructive) {
                Task{ await repository.deleteArtists([artist]) }
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
