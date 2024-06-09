//
//  PlayerArtView.swift
//  Boomic
//
//  Created by Kevin Kelly on 4/14/24.
//

import SwiftUI

private typealias C = ViewConstants

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
    
    private func artID() -> String {
        switch player.art {
        case .local(let path): return path.relative
        case .embedded(_, let hash): return hash
        case .none: return "none"
        }
    }
}

#Preview {
    PlayerArtView()
        .environment(PreviewMocks.shared.previewPlayerWithSong())
}
