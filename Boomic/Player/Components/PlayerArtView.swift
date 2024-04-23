//
//  PlayerArtView.swift
//  Boomic
//
//  Created by Kevin Kelly on 4/14/24.
//

import SwiftUI

struct PlayerArtView: View {
    @Environment(\.player) private var player
    let cornerRadius: CGFloat
    
    init(cornerRadius: CGFloat = C.albumCornerRadius) {
        self.cornerRadius = cornerRadius
    }
        
    var body: some View {
        MediaArtView(player.art, cornerRadius: cornerRadius)
            .id(artID())
    }
    
    private typealias C = ViewConstants
    
    private func artID() -> String {
        switch player.art {
        case .local(let url): return url.path()
        case .embedded(_, let hash): return hash
        case .none: return "none"
        }
    }
}

#Preview {
    PlayerArtView()
        .environment(previewPlayerWithSong())
}
