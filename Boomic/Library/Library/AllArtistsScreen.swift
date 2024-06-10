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
   
    @State private var artists: [Artist] = []
    
    @State private var predicate: String = ""
    private var primaryOnly: Bool { preferences.localSearchOnlyPrimary }
   
    var body: some View {
        @Bindable var nav = navigator
        
        ScrollView {
            ArtistGrid(
                key: Preferences.GridKeys.allArtists
                , artists: artists.search(predicate, primaryOnly: primaryOnly)
                , title: "Artists"
                , titleFont: F.screenTitle
                , buttonsInToolbar: true
            )
            .padding(.horizontal, C.gridPadding)
        }
        
        .searchable(text: $predicate, isPresented: $nav.isSearchFocused)
        
        .task {
            artists = await repository.getArtists(for: nil)
        }
    }
}

#Preview {
    AllArtistsScreen()
        .environment(\.repository, PreviewMocks.shared.previewRepository())
}
