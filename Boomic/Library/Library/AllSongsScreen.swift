//
//  AllSongsScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/17/24.
//

import SwiftUI
import Models

private typealias C = ViewConstants
private typealias F = ViewConstants.Fonts

struct AllSongsScreen: View {
    @Environment(\.navigator) private var navigator
    @Environment(\.preferences) private var preferences
    @Environment(\.repository) private var repository
    
    let filter: ((Song) -> Bool)?
    
    private var songs: [Song] {
        if let filter = filter {
            return repository.songs().filter(filter)
        } else {
            return repository.songs()
        }
    }
    
    @State private var predicate: String = ""
    private var primaryOnly: Bool { preferences.localSearchOnlyPrimary }
    
    init(filter: ((Song) -> Bool)? = nil) {
        self.filter = filter
    }
    
    var body: some View {
        @Bindable var nav = navigator
        
        SongGrid(
            songs: songs.search(predicate, primaryOnly: primaryOnly)
            , key: Preferences.GridKeys.allSongs
            , header: .buttonsInToolbar
            , title: "Songs"
            , titleFont: F.screenTitle
            , queueName: "All Songs"
            , showTrackNumber: false
        )
        
        .searchable(text: $predicate, isPresented: $nav.isSearchFocused)
    }
}

#Preview {
    AllSongsScreen()
        .environment(\.repository, PreviewMocks.shared.previewRepository())
}
