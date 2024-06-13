//
//  AllArtistsScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/17/24.
//

import SwiftUI
import Models

private typealias C = ViewConstants
private typealias F = ViewConstants.Fonts

struct AllArtistsScreen: View {
    @Environment(\.navigator) private var navigator
    @Environment(\.preferences) private var preferences
    @Environment(\.repository) private var repository
   
    private var artists: [Artist] { repository.artists() }
    
    @State private var predicate: String = ""
    private var primaryOnly: Bool { preferences.localSearchOnlyPrimary }
   
    var body: some View {
        @Bindable var nav = navigator
        
        ArtistGrid(
            artists: artists.search(predicate, primaryOnly: primaryOnly)
            , key: Preferences.GridKeys.allArtists
            , header: .buttonsInToolbar
            , selectable: true
            , title: "Artists"
            , titleFont: F.screenTitle
        )
        
        .searchable(text: $predicate, isPresented: $nav.isSearchFocused)
    }
}

#Preview {
    AllArtistsScreen()
        .environment(\.repository, PreviewMocks.shared.previewRepository())
}
