//
//  ContentView.swift
//  Boomic
//
//  Created by Kevin Kelly on 2/7/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.preferences) private var preferences
    
    var body: some View { 
        PlayerWrapper { TabsScreen() }
            .tint(preferences.accentColor)
    }
}

#Preview {
    ContentView()
        .environment(\.repository, PreviewMocks.shared.previewRepository())
        .environment(\.player, PreviewMocks.shared.previewPlayer())
        .environment(\.navigator, PreviewMocks.shared.previewNavigator())
        .environment(\.preferences, PreviewMocks.shared.previewPreferences())
}



