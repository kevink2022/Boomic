//
//  SongBarWrapper.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/31/24.
//

import SwiftUI

private typealias C = ViewConstants

struct SongBarWrapper<Content: View> : View{
    @Environment(\.player) private var player
    
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        VStack(spacing: 0) {
            content()
            
            if let _ = player.song {
                
                Divider()
                
                Button {
                    player.fullscreen = true
                } label: {
                    SongBar()
                        .padding(C.gridPadding)
                }
                .foregroundStyle(.primary)
                
                Divider()
            }
        }
        .background {
            ZStack {
                Color(.systemBackground)
                    .overlay {
                        PlayerArtView()
                            .blur(radius: C.backgroundBlurRadius)
                            .scaleEffect(C.backgroundBlurScaleEffect)
                            .opacity(C.backgroundBlurOpacity)
                    }
            }
            .clipped()
        }
    }
}

#Preview {
    SongBarWrapper { LibraryScreen() }
        .environment(\.player, previewPlayer())
}
