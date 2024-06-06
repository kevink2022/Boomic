//
//  TabsScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/5/24.
//

import SwiftUI

private typealias SI = ViewConstants.SystemImages


struct TabsScreen: View {
    @Environment(\.navigator) private var navigator
    @Environment(\.preferences) private var preferences
    
    var body: some View {
        @Bindable var navigator = navigator
        
        TabView(selection: $navigator.tab){
            ForEach(preferences.tabOrder) { tab in
                switch tab {
                case .home:
                    SongBarWrapper { LibraryScreen() }
                        .tabItem { Label("Home", systemImage: SI.home) }
                        .tag(TabNavigation.home)
                    
                case .settings:
                    SongBarWrapper { SettingsScreen() }
                        .tabItem { Label("Settings", systemImage: SI.settings) }
                        .tag(TabNavigation.settings)
                    
                case .mixer:
                    SongBarWrapper { MixerScreen() }
                        .tabItem { Label("Mixer", systemImage: SI.mixer) }
                        .tag(TabNavigation.mixer)
                    
                case .search:
                    SongBarWrapper { SearchScreen() }
                        .tabItem { Label("Search", systemImage: SI.search) }
                        .tag(TabNavigation.search)
                }
            }
        }
    }
}

#Preview {
    TabsScreen()
}
