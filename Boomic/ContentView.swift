//
//  ContentView.swift
//  Boomic
//
//  Created by Kevin Kelly on 2/7/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.player) private var player
    @State var playerOffset: CGFloat = 800
    
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
            .onChange(of: player.fullscreen) {
                if player.fullscreen == true {
                    playerOffset = 800
                    withAnimation(.spring(duration: 0.2)) { playerOffset = 0 }
                }
            }

            if player.fullscreen {
                PlayerScreen()
                    .offset(y: playerOffset)
                    .gesture(DragGesture()
                        .onChanged { value in
                            if value.translation.height > 0 {
                                playerOffset = value.translation.height
                            }
                        }
                        .onEnded { value in
                            let velocity = value.predictedEndTranslation.height - value.translation.height

                            if playerOffset > 300 || velocity > 250 {
                                withAnimation(.easeOut) {
                                    playerOffset = 1000
                                } completion: {
                                    player.fullscreen = false
                                }
                            } else {
                                withAnimation(.easeOut) { playerOffset = 0 }
                            }
                        }
                    )
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.repository, livePreviewRepository())
        .environment(\.player, previewPlayer())
}



