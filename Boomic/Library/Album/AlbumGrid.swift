//
//  AlbumGridLink.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/18/24.
//

import SwiftUI
import Models

private typealias C = ViewConstants
private typealias F = ViewConstants.Fonts

struct AlbumGrid: View {
    @Environment(\.navigator) private var navigator
    
    let title: String
    let key: String
    let titleFont: Font
    let buttonsInToolbar: Bool
    let albums: [Album]
    
    init(
        key: String
        , albums: [Album]
        , title: String = "Artists"
        , titleFont: Font = F.sectionTitle
        , buttonsInToolbar: Bool = false
    ) {
        self.key = key
        self.albums = albums
        self.title = title
        self.titleFont = titleFont
        self.buttonsInToolbar = buttonsInToolbar
    }
    
    var body: some View {
        GridList(
            title: title
            , key: key
            , titleFont: titleFont
            , entries: albums.map({ album in
                GridListEntry(
                    label: album.title
                    , subLabel: album.artistName ?? "Unknown Artist"
                    , action: { navigator.library.navigateTo(album) }
                    , icon: {
                        MediaArtView(album.art, cornerRadius: C.albumCornerRadius)
                    }
                )
            })
        )
    }
}
