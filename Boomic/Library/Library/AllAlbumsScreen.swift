//
//  AllAlbumsScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/16/24.
//

import SwiftUI

import Models

private typealias C = ViewConstants
private typealias F = ViewConstants.Fonts

struct AllAlbumsScreen: View {
    @Environment(\.navigator) private var navigator
    @Environment(\.preferences) private var preferences
    @Environment(\.repository) private var repository
    
    private var albums: [Album] { repository.albums() }
    
    @State private var predicate: String = ""
    private var primaryOnly: Bool { preferences.localSearchOnlyPrimary }

    var body: some View {
        @Bindable var nav = navigator
        
        AlbumGrid(
            albums: albums.search(predicate, primaryOnly: primaryOnly)
            , key: Preferences.GridKeys.allAlbums
            , header: .buttonsInToolbar
            , selectable: true
            , title: "Albums"
            , titleFont: F.screenTitle
        )
        
        .searchable(text: $predicate, isPresented: $nav.isSearchFocused)
    }
}

#Preview {
    AllAlbumsScreen()
        .environment(\.repository, PreviewMocks.shared.previewRepository())
}


