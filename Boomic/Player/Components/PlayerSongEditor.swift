//
//  PlayerSongEditor.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/23/24.
//

import SwiftUI
import Models

struct PlayerSongEditor: View {
    
    @State private var tags: Set<Tag>
    
    init(
        tags: Set<Tag>
    ) {
        self.tags = tags
    }
    
    var body: some View {
        ZStack {
            Color.primary
                .opacity(0.5)
            
            VStack {
                Spacer()
                
                TagEntryField(tags: $tags, editing: true)
                    .opacity(0.3)
                    .frame(maxHeight: 40)
            }
        }
    }
}

#Preview {
    MediaArtView(nil)
        .overlay {
            PlayerSongEditor(tags: [])
        }
}
