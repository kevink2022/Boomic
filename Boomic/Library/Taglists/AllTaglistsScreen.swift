//
//  AllTaglistsScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/17/24.
//

import SwiftUI
import Models

private typealias C = ViewConstants
private typealias F = ViewConstants.Fonts
private typealias SI = ViewConstants.SystemImages

struct AllTaglistsScreen: View {
    @Environment(\.navigator) private var navigator
    @Environment(\.repository) private var repository
    
    private var taglists: [Taglist] {
        repository.taglists()        
    }
    
    var body: some View {
        GridList(
            header: .buttonsInToolbar
            , title: "Taglists"
            , titleFont: F.screenTitle
            , entries: [
                GridListEntry(
                    label: "New"
                    , action: { navigator.library.navigateTo(MiscLibraryNavigation.newTaglist) }
                    , icon: {
                        AnyView(LibraryGridEntry(imageName: SI.add))
                    }
                )
            ] 
            
            + taglists.map { list in
                GridListEntry(
                    label: list.label
                    , action: { navigator.library.navigateTo(list) }
                    , icon: {
                         AnyView(MediaArtView(nil, cornerRadius: C.albumCornerRadius))
                    }
                )
            }
        )
    }
}

#Preview {
    NavigationStack {
        AllTaglistsScreen()
    }
}
