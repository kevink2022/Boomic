//
//  ShowAllSelections.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/12/24.
//

import SwiftUI
import Models

private typealias F = ViewConstants.Fonts

struct ShowAllSelections: View {
    @Environment(\.repository) var repository
    @Environment(\.selector) var selector

    var ids: [UUID] { Array(selector.selected) }
    
    var body: some View {
        ScrollView {
            switch selector.group {
            case .songs:
                SongGrid(
                    songs: repository.songs(ids)
                    , config: .smallIconList
                    , header: .buttonsHidden
                    , selectable: false
                    , disabled: true
                    , title: "Selected Songs"
                    , titleFont: F.screenTitle
                    , queueName: "Selected Songs"
                    , showTrackNumber: false
                )
                
            case .albums:
                AlbumGrid(
                    albums: repository.albums(ids)
                    , config: .smallIconList
                    , header: .buttonsHidden
                    , selectable: false
                    , disabled: true
                    , title: "Selected Albums"
                    , titleFont: F.screenTitle
                )
                
            case .artists:
                ArtistGrid(
                    artists: repository.artists(ids)
                    , config: .smallIconList
                    , header: .buttonsHidden
                    , selectable: false
                    , disabled: true
                    , title: "Selected Artists"
                    , titleFont: F.screenTitle
                )
                
            default: EmptyView()
            }
        }
    }
}

#Preview {
    ShowAllSelections()
}
