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
    
    let title: String
    let key: String
    let titleFont: Font
    let buttonsInToolbar: Bool
    let artists: [Artist]
    
    init(
        key: String
        , artists: [Artist]
        , title: String = "Artists"
        , titleFont: Font = F.sectionTitle
        , buttonsInToolbar: Bool = false
    ) {
        self.artists = artists
        self.key = key
        self.title = title
        self.titleFont = titleFont
        self.buttonsInToolbar = buttonsInToolbar
    }
    
    var body: some View {
        GridList(
            title: title
            , key: key
            , titleFont: titleFont
            , buttonsInToolbar: buttonsInToolbar
            , entries: artists.map({ artist in
                GridListEntry(
                    label: artist.name
                    , action: { navigator.library.navigateTo(artist) }
                    , icon: {
                        MediaArtView(artist.art)
                            .clipShape(Circle())
                    }
                )
            })
        )
    }
}
