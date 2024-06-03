//
//  SongBarWrapper.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/31/24.
//

import SwiftUI

private typealias C = ViewConstants
private typealias A = ViewConstants.Animations

struct SongBarWrapper<Content: View> : View {
    @Environment(\.navigator) private var navigator
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
                    navigator.openPlayer()
                } label: {
                    SongBar()
                        .padding(C.gridPadding)
                }
                .foregroundStyle(.primary)
                .highPriorityGesture(
                    DragGesture().onEnded { value in
                        let offset = value.translation.width
                        let velocity = abs(value.predictedEndTranslation.width - value.translation.width)
                        
                        let velocityTrigger: CGFloat = 100
                        let swipeLeft = offset > 0 && velocity > velocityTrigger
                        let swipeRight = offset < 0 && velocity > velocityTrigger

                        if swipeRight {
                            withAnimation(A.standard) { player.next() }
                        } else if swipeLeft {
                            withAnimation(A.standard) { player.previous() }
                        }
                    }
                )
                
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
        .environment(\.player, PreviewMocks.shared.previewPlayer())
        .environment(\.navigator, PreviewMocks.shared.previewNavigator())
}
