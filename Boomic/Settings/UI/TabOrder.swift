//
//  TabOrder.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/4/24.
//

import SwiftUI

private typealias SI = ViewConstants.SystemImages

struct TabOrder: View {
    @Environment(\.preferences) private var preferences
    
    var body: some View {
        @Bindable var preferences = preferences
        
        Text("Rearrange the list to order the tabs at the bottom of the screen. (Note: Move one spot at a time to avoid the menu from resetting).")
        
        List($preferences.tabOrder, id: \.self, editActions: .move) { $tab in
            HStack {
                switch tab {
                case .home:
                    Image(systemName: SI.home)
                    Text("Home")
                case .settings:
                    Image(systemName: SI.settings)
                    Text("Settings")
                case .mixer:
                    Image(systemName: SI.mixer)
                    Text("Mixer")
                case .search:
                    Image(systemName: SI.search)
                    Text("Search")
                }
            }
        }
    }
}

#Preview {
    TabOrder()
}
