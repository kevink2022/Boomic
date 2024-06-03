//
//  ContentView.swift
//  Boomic
//
//  Created by Kevin Kelly on 2/7/24.
//

import SwiftUI

private typealias A = ViewConstants.Animations

struct ContentView: View {
    @Environment(\.navigator) private var navigator
    @Environment(\.player) private var player
    
    var body: some View { 
        @Bindable var navigator = navigator
        
        ZStack {
            TabView(selection: $navigator.tab){
                SongBarWrapper { LibraryScreen() }
                    .tabItem { Label("Home", systemImage: "music.note.house") }
                    .tag(TabNavigation.home)
                
                SongBarWrapper { SettingsScreen() }
                    .tabItem { Label("Settings", systemImage: "gear") }
                    .tag(TabNavigation.settings)
                
                SongBarWrapper { MixerScreen() }
                    .tabItem { Label("Mixer", systemImage: "slider.vertical.3") }
                    .tag(TabNavigation.mixer)
                
                SongBarWrapper { SearchScreen() }
                    .tabItem { Label("Search", systemImage: "magnifyingglass") }
                    .tag(TabNavigation.search)
            }
            .onTapGesture(count: 2) {
                switch navigator.tab {
                case .home: navigator.library.removeLast(navigator.library.count)
                default: break
                }
            }
            .onChange(of: navigator.playerFullscreen) {
                if navigator.playerFullscreen == true {
                    navigator.playerOffset = 800
                    withAnimation(A.showPlayer) { navigator.playerOffset = 0 }
                }
            }

            if navigator.playerFullscreen {
                PlayerScreen()
                    .offset(y: navigator.playerOffset)
                    .gesture(DragGesture()
                        .onChanged { value in
                            if value.translation.height > 0 {
                                navigator.playerOffset = value.translation.height
                            }
                        }
                        .onEnded { value in
                            let velocity = value.predictedEndTranslation.height - value.translation.height

                            if navigator.playerOffset > 300 || velocity > 250 {
                                navigator.closePlayer()
                            } else {
                                withAnimation(.easeOut) { navigator.playerOffset = 0 }
                            }
                        }
                    )
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.repository, PreviewMocks.shared.previewRepository())
        .environment(\.player, PreviewMocks.shared.previewPlayer())
        .environment(\.navigator, PreviewMocks.shared.previewNavigator())
}



