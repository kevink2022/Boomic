//
//  AlbumMenu.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/11/24.
//

import SwiftUI
import Models

private typealias SI = ViewConstants.SystemImages

struct AlbumMenu: View {
    @Environment(\.navigator) private var navigator
    @Environment(\.repository) private var repository
    @Environment(\.selector) private var selector

    let album: Album
    let navigateOnSelect: Bool
    
    init(
        album: Album
        , navigateOnSelect: Bool = false
    ) {
        self.album = album
        self.navigateOnSelect = navigateOnSelect
    }
    
    var body: some View {
        if !selector.active {
            Button {
                selector.selectGroup(.albums)
                selector.toggleSelect(album.id, group: .albums)
                if navigateOnSelect {
                    navigator.library.navigateTo(LibraryNavigation.albums, clearingPath: true)
                }
            } label: {
                Label("Select Album", systemImage: SI.select)
            }
        } else if selector.group == .songs {
            Button {
                selector.select(album.songs)
            } label: {
                Label("Select All Songs", systemImage: SI.select)
            }
        }
        
        Menu {
            Button {
                navigator.presentSheet(AlbumUpdateSheet(albums: [album]))
            } label: {
                Label("Edit Album", systemImage: SI.edit)
            }
            
            Button(role: .destructive) {
                Task{ await repository.deleteAlbums([album]) }
            } label: {
                Label("Delete Album", systemImage: SI.delete)
            }
            
        } label: {
            Label("Edit Album", systemImage: SI.edit)
        }
    }
}

#Preview {
    AlbumMenu(album: PreviewMocks.shared.previewAlbum())
}
