//
//  ContentView.swift
//  Boomic
//
//  Created by Kevin Kelly on 2/7/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.player) private var player
    
    var body: some View {
        ZStack {
            TabView {
                SongBarWrapper { LibraryScreen() }
                    .tabItem { Label("Home", systemImage: "music.note.house") }
                
                SongBarWrapper { SettingsScreen() }
                    .tabItem { Label("Settings", systemImage: "gear") }
                
                SongBarWrapper { MixerScreen() }
                    .tabItem { Label("Mixer", systemImage: "slider.vertical.3") }
                
                SongBarWrapper { SearchScreen() }
                    .tabItem { Label("Search", systemImage: "magnifyingglass") }
            }
            if player.fullscreen {
                PlayerScreen()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.repository, livePreviewRepository())
        .environment(\.player, previewPlayer())
}



