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
    let header: GridListHeader
    let title: String
    let titleFont: Font
    
    init(
        artists: [Artist]
        , key: String? = nil
        , header: GridListHeader = .standard
        , title: String = "Artists"
        , titleFont: Font = F.sectionTitle
    ) {
        self.artists = artists
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
            , hasSubLabels: false
            , entries: artists.map({ artist in
                GridListEntry(
                    label: artist.name
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
