//
//  SongBarWrapper.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/31/24.
//

import SwiftUI

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
                
                Divider()
            }
        }
    }
    
    private typealias C = ViewConstants
}

#Preview {
    SongBarWrapper { LibraryScreen() }
        .environment(\.player, previewPlayer())
}
