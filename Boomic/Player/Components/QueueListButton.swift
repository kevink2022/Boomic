//
//  QueueListButton.swift
//  Boomic
//
//  Created by Kevin Kelly on 4/22/24.
//

import SwiftUI
import Models

private typealias C = ViewConstants
private typealias F = ViewConstants.Fonts
private typealias A = ViewConstants.Animations
private typealias SI = ViewConstants.SystemImages

enum QueueListDisplayMode: CaseIterable {
    case duration, delete, swap
    
    var systemImage: String {
        switch self {
        case .duration: SI.queueListDuration
        case .delete: SI.queueListDelete
        case .swap: SI.queueListSwap
        }
    }
    
    mutating func toggle() {
        let allCases = QueueListDisplayMode.allCases
        let index = allCases.firstIndex(of: self) ?? 0
        let nextIndex = index == allCases.endIndex - 1 ? 0 : index + 1
        self = allCases[nextIndex]
    }
}

struct QueueListButton: View {
    @Environment(\.player) private var player
    let song: Song
    let queueIndex: Int
    @Binding var displayMode: QueueListDisplayMode
    let scrollToTop: (() -> Void)?
    
    init(
        song: Song
        , queueIndex: Int
        , displayMode: Binding<QueueListDisplayMode>
        , onSongChange: (() -> Void)? = nil
    ) {
        self.song = song
        self.queueIndex = queueIndex
        self._displayMode = displayMode
        self.scrollToTop = onSongChange
    }
    
    var body: some View {
        Button {
            player.setSong(song, forwardQueueIndex: queueIndex)
            if let scrollToTop = scrollToTop { scrollToTop() }
        } label: {
            HStack {
                MediaArtView(song.art, cornerRadius: C.smallAlbumCornerRadius)
                    .frame(height: C.smallAlbumFrame)
                
                VStack(alignment: .leading) {
                    Text(song.label)
                        .font(F.listEntryTitle)
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
                    AnimatedButton(A.standard) {
                        player.remove(forwardIndex: queueIndex)
                    } label: {
                        Image(systemName: SI.queueListDelete)
                            .font(.title)
                    }
                case .swap:
                    AnimatedButton(A.standard) {
                        player.swap(queueIndex, with: queueIndex-1)
                    } label: {
                        Image(systemName: SI.queueListMoveUp)
                            .font(.title)
                    }
                    .disabled(queueIndex == 0)
                    
                    AnimatedButton(A.standard) {
                        player.swap(queueIndex, with: queueIndex+1)
                    } label: {
                        Image(systemName: SI.queueListMoveDown)
                            .font(.title)
                    }
                    .disabled(queueIndex+1 == player.queue?.restOfQueue.endIndex)
                }
            }
        }
        .contextMenu(ContextMenu(menuItems: {
            Button {
                player.remove(forwardIndex: queueIndex)
                withAnimation(A.standard) { player.addNext(song) }
            } label: {
                Label("Move to top", systemImage: SI.topOfQueue)
            }
            .disabled(queueIndex == 0)
            
            Button {
                player.remove(forwardIndex: queueIndex)
                withAnimation(A.standard) { player.addToEnd(song) }
            } label: {
                Label("Move to bottom", systemImage: SI.bottomOfQueue)
            }
            .disabled(queueIndex+1 == player.queue?.restOfQueue.endIndex)
        }))
    }
}

#Preview {
    QueueListButton(song: PreviewMocks.shared.previewSong(), queueIndex: 2, displayMode: .constant(.duration))
}
