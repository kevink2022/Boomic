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
    
    let albums: [Album]
    
    let key: String?
    let header: GridListHeader
    let title: String
    let titleFont: Font
    
    init(
        albums: [Album]
        , key: String? = nil
        , header: GridListHeader = .standard
        , title: String = "Artists"
        , titleFont: Font = F.sectionTitle
    ) {
        self.albums = albums
        self.key = key
        self.header = header
        self.title = title
        self.titleFont = titleFont
    }
    
    var body: some View {
        GridList(
            key: key
            , header: header
            , title: title
            , titleFont: titleFont
            , textAlignment: .leading
            , entries: albums.map({ album in
                GridListEntry(
                    label: album.title
                    , subLabel: album.artistName ?? "Unknown Artist"
                    , action: { navigator.library.navigateTo(album) }
                    , icon: {
                        MediaArtView(album.art, cornerRadius: C.albumCornerRadius)
                    }
                    , menu: {
                        AlbumMenu(album: album)
                    }
                )
            })
        )
    }
}
