//
//  AllTaglistsScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/17/24.
//

import SwiftUI
import Models

private typealias F = ViewConstants.Fonts
private typealias SI = ViewConstants.SystemImages

struct AllTaglistsScreen: View {
    @Environment(\.navigator) private var navigator
    
    var body: some View {
        GridList(
            header: .buttonsInToolbar
            , title: "Taglists"
            , titleFont: F.screenTitle
            , entries: [
                GridListEntry(
                    label: "New"
                    , action: { navigator.library.navigateTo(Taglist.empty) }
                    , icon: {
                        LibraryGridEntry(imageName: SI.add)
                    }
                )
            ]
        )
    }
}

#Preview {
    NavigationStack {
        AllTaglistsScreen()
    }
}
