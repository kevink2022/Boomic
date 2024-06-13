//
//  ContentView.swift
//  Boomic
//
//  Created by Kevin Kelly on 2/7/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.navigator) private var navigator
    @Environment(\.preferences) private var preferences
    
    var body: some View {
        @Bindable var navigator = navigator
        
        PlayerWrapper { TabsScreen() }
            .tint(preferences.accentColor)
            .sheet(isPresented: $navigator.showSheet) {
                if let content = navigator.sheetContent {
                    content
                }
            }
    }
}

#Preview {
    ContentView()
        .environment(\.repository, PreviewMocks.shared.previewRepository())
        .environment(\.player, PreviewMocks.shared.previewPlayer())
        .environment(\.navigator, PreviewMocks.shared.previewNavigator())
        .environment(\.preferences, PreviewMocks.shared.previewPreferences())
}



