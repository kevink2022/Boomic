//
//  ArtistGridEntry.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/17/24.
//

import SwiftUI
import Models

private typealias F = ViewConstants.Fonts

struct ArtistGrid: View {
    @Environment(\.navigator) private var navigator
    
    let artists: [Artist]
    
    let key: String?
    let config: GridListConfiguration
    let header: GridListHeader
    let selectable: Bool
    let disabled: Bool
    let title: String
    let titleFont: Font
    
    init(
        artists: [Artist]
        , key: String? = nil
        , config: GridListConfiguration = .threeColumns
        , header: GridListHeader = .standard
        , selectable: Bool = false
        , disabled: Bool = false
        , title: String = "Artists"
        , titleFont: Font = F.sectionTitle
    ) {
        self.artists = artists
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
            , hasSubLabels: false
            , entries: artists.map({ artist in
                GridListEntry(
                    label: artist.name
                    , selectionGroup: .artists
                    , selectionID: artist.id
                    , action: { navigator.library.navigateTo(artist) }
                    , icon: {
                        MediaArtView(artist.art)
                            .clipShape(Circle())
                    }
                    , menu: {
                        ArtistMenu(artist: artist)
                    }
                )
            })
        )
    }
}
