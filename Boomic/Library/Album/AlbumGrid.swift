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
    @Environment(\.isSearchTab) private var isSearchTab
    
    let albums: [Album]
    
    let key: String?
    let config: GridListConfiguration
    let header: GridListHeader
    let selectable: Bool
    let disabled: Bool
    let title: String
    let titleFont: Font
    
    init(
        albums: [Album]
        , key: String? = nil
        , config: GridListConfiguration = .threeColumns
        , header: GridListHeader = .standard
        , selectable: Bool = false
        , disabled: Bool = false
        , title: String = "Artists"
        , titleFont: Font = F.sectionTitle
    ) {
        self.albums = albums
        self.key = key
        self.config = config
        self.header = header
        self.selectable = selectable
        self.disabled = disabled
        self.title = title
        self.titleFont = titleFont
    }
    
    var body: some View {
        GridList(
            key: key
            , config: config
            , header: header
            , selectable: selectable
            , disabled: disabled
            , title: title
            , titleFont: titleFont
            , textAlignment: .leading
            , entries: albums.map({ album in
                GridListEntry(
                    label: album.title
                    , subLabel: album.artistName ?? "Unknown Artist"
                    , selectionGroup: .albums
                    , selectionID: album.id
                    , action: {
                        if isSearchTab {
                            navigator.search.navigateTo(album)
                        } else {
                            navigator.library.navigateTo(album)
                        }
                    }
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
