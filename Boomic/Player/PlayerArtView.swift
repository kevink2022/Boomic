//
//  PlayerArtView.swift
//  Boomic
//
//  Created by Kevin Kelly on 4/14/24.
//

import SwiftUI

struct PlayerArtView: View {
    @Environment(\.player) private var player
    @State private var forceUpdateToggle: Bool = false
        
    var body: some View {
        MediaArtView(player.art)
            .clipShape(RoundedRectangle(cornerSize: CGSize(
                width: C.albumCornerRadius,
                height: C.albumCornerRadius
            )))
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
