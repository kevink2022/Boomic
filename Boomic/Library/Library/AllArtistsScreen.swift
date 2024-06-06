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
    @Environment(\.repository) private var repository
    @Environment(\.navigator) private var navigator
    @State private var artists: [Artist] = []
    
    // dynamic grid
    let column: GridItem = GridItem.init(.flexible())
    @State var columnCount = 2
    @State var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    @State var showTitleButtons = false
    
    let left = "chevron.left.circle"
    let right = "chevron.right.circle"
    
    
    var body: some View {
        ScrollView {
            GridList(
                title: "Artists"
                , key: Preferences.GridKeys.allArtists
                , titleFont: F.screenTitle
                , buttonsInToolbar: true
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
            .padding(.horizontal, C.gridPadding)
        }
        
        
        .task {
            artists = await repository.getArtists(for: nil)
        }
    }
}

#Preview {
    AllArtistsScreen()
        .environment(\.repository, PreviewMocks.shared.previewRepository())
}
