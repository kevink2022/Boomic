//
//  PlayerWrapper.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/5/24.
//

import SwiftUI

private typealias A = ViewConstants.Animations

struct PlayerWrapper<Content: View> : View {
    @Environment(\.navigator) private var navigator
    @Environment(\.player) private var player
    
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        ZStack {
            content()
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
    PlayerWrapper {
        Text("Hello World")
    }
}
