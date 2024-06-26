//
//  ContentView.swift
//  Boomic
//
//  Created by Kevin Kelly on 2/7/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(\.navigator) private var navigator
    @Environment(\.preferences) private var preferences
    
    var body: some View {
        @Bindable var navigator = navigator
        
        PlayerWrapper { TabsScreen() }
       
            .fileImporter(
                isPresented: $navigator.showFiles
                , allowedContentTypes: navigator.fileTypes
                , allowsMultipleSelection: navigator.allowMultiSelection
                , onCompletion: navigator.filePickerCompletion
            )
            
            .sheet(isPresented: $navigator.showSheet) {
                if let content = navigator.sheetContent {
                    content
                }
            }
        
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



