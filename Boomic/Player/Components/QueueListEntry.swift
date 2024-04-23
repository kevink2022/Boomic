//
//  QueueListEntry.swift
//  Boomic
//
//  Created by Kevin Kelly on 4/22/24.
//

import SwiftUI
import Models

enum QueueListDisplayMode: CaseIterable {
    case duration, delete, swap
    
    var systemImage: String {
        switch self {
        case .duration: "clock"
        case .delete: "minus.circle"
        case .swap: "arrow.up.arrow.down.circle"
        }
    }
    
    mutating func toggle() {
        let allCases = QueueListDisplayMode.allCases
        let index = allCases.firstIndex(of: self) ?? 0
        let nextIndex = index == allCases.endIndex - 1 ? 0 : index + 1
        self = allCases[nextIndex]
    }
}

struct QueueListEntry: View {
    @Environment(\.player) private var player
    let song: Song
    let queueIndex: Int
    @Binding var displayMode: QueueListDisplayMode
    
    var body: some View {
        HStack {
            MediaArtView(song.art, cornerRadius: C.smallAlbumCornerRadius)
                .frame(height: C.smallAlbumFrame)
            
            VStack(alignment: .leading) {
                Text(song.label)
                    .font(F.body)
                    .lineLimit(1)
                
                if let artist = song.artistName {
                    Text(artist)
                        .font(F.listDuration)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            switch displayMode {
            case .duration:
                Text(song.duration.formatted)
                    .font(F.listDuration)
            case .delete:
                Button {
                    withAnimation { player.remove(forwardIndex: queueIndex) }
                } label: {
                    Image(systemName: "minus.circle")
                        .font(.title)
                }
            case .swap:
                Button {
                    withAnimation { player.swap(queueIndex, with: queueIndex-1) }
                } label: {
                    Image(systemName: "arrow.up.circle")
                        .font(.title)
                }
                .disabled(queueIndex == 0)
                
                Button {
                    withAnimation { player.swap(queueIndex, with: queueIndex+1) }
                } label: {
                    Image(systemName: "arrow.down.circle")
                        .font(.title)
                }
                .disabled(queueIndex+1 == player.queue?.restOfQueue.endIndex)
            }
        }
    }
    
    private typealias C = ViewConstants
    private typealias F = ViewConstants.Fonts
}

#Preview {
    QueueListEntry(song: previewSong(), queueIndex: 2, displayMode: .constant(.duration))
}
