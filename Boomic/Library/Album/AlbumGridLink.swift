//
//  AlbumGridLink.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/18/24.
//

import SwiftUI
import Models


struct AlbumGridLink: View {
    @Environment(\.navigator) private var navigator
    let album: Album
    
    var body: some View {
        Button {
            navigator.library.append(album)
        } label: {
            AlbumGridEntry(album: album)
        }
        .foregroundStyle(.primary)
    }
}

#Preview {
    AlbumGridLink(album: PreviewMocks.shared.previewAlbum())
        .environment(\.navigator, PreviewMocks.shared.previewNavigator())
}
