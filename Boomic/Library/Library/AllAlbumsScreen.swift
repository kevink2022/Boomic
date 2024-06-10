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
    
    @State private var albums: [Album] = []
    @State private var predicate: String = ""
    private var primaryOnly: Bool { preferences.localSearchOnlyPrimary }

    var body: some View {
        @Bindable var nav = navigator
        
        ScrollView {
            AlbumGrid(
                key: Preferences.GridKeys.allAlbums
                , albums: albums.search(predicate, primaryOnly: primaryOnly)
                , title: "Albums"
                , titleFont: F.screenTitle
                , buttonsInToolbar: true
            )
            .padding(.horizontal, C.gridPadding)
        }
        
        .searchable(text: $predicate, isPresented: $nav.isSearchFocused)
        
        .task {
            albums = await repository.getAlbums(for: nil)
        }
    }
}

#Preview {
    AllAlbumsScreen()
        .environment(\.repository, PreviewMocks.shared.previewRepository())
}


