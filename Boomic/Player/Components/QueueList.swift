//
//  QueueList.swift
//  Boomic
//
//  Created by Kevin Kelly on 4/15/24.
//

import SwiftUI

struct QueueList: View {
    @Environment(\.player) private var player

    var body: some View {
        VStack(spacing: 0){
            Divider()
            
            if let queue = player.queue {
                ScrollView { ScrollViewReader { value in
                    LazyVStack(spacing: 0) {
                        ForEach(queue.restOfQueue.indices, id: \.self) { index in
                            let song = queue.restOfQueue[index]
                            
                            Button {
                                player.setSong(song, forwardQueueIndex: index)

                                withAnimation {
                                    value.scrollTo(0)
                                }
                            } label: {
                                SongListEntry(song: song)
                            }
                            .foregroundStyle(.primary)
                            .id(song)
                            .padding(C.gridPadding)
                        }
                    }
                }}
            }
            Divider()
        }
    }
    
    private typealias C = ViewConstants
}

#Preview {
    QueueList()
}
