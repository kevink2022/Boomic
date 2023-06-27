//
//  AppTabView.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/26/23.
//

import SwiftUI

struct AppTabView: View
{
    @EnvironmentObject var manager : BoomicManager
    
    var body: some View
    {
        VStack
        {
            /// All tabviews must have CurrentSongBar() at the bottom of a VStack
            TabView
            {
                CategoriesView()
                    .tabItem {
                        Label("Home", systemImage: "music.note.house")
                    }
                
                // Equalizer
                SettingsView()
                    .tabItem {
                        Label("EQ", systemImage: "slider.vertical.3")
                    }
                
                // Search
                SettingsView()
                    .tabItem {
                        Label("Search", systemImage: "waveform.and.magnifyingglass")
                    }
                
                // Settings??
            }
        }
    }
}

struct AppTabView_Previews: PreviewProvider {
    static var previews: some View {
        AppTabView()
    }
}
