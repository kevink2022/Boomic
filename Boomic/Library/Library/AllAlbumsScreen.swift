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
    @Environment(\.repository) private var repository
    
    @State private var albums: [Album] = []
    @State var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        ScrollView {
            GridList(
                title: "Albums"
                , key: Preferences.GridKeys.allAlbums
                , titleFont: F.screenTitle
                , buttonsInToolbar: true
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
            .padding(.horizontal, C.gridPadding)
        }
        
        
        .task {
            albums = await repository.getAlbums(for: nil)
        }
    }
}

#Preview {
    AllAlbumsScreen()
        .environment(\.repository, PreviewMocks.shared.previewRepository())
}


