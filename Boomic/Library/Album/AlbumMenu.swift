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
    @Environment(\.repository) private var repository
    let album: Album
    
    var body: some View {
        Menu {
            Button {
                
            } label: {
                Label("Update Album", systemImage: SI.unrated)
            }
            
            Button(role: .destructive) {
                Task{ await repository.deleteAlbum(album) }
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
