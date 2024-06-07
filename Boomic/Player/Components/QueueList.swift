//
//  QueueList.swift
//  Boomic
//
//  Created by Kevin Kelly on 4/15/24.
//

import SwiftUI

private typealias C = ViewConstants
private typealias F = ViewConstants.Fonts

struct QueueList: View {
    @Environment(\.player) private var player
    @State var listDisplay: QueueListDisplayMode = .duration

    var body: some View {
        VStack(spacing: 0) {
            
            HStack {
                Text(player.queue?.name ?? "Queue")
                    .lineLimit(1)
                    .font(F.listEntryTitle)
                    .opacity(C.queueNameOpacity)
                
                Spacer()
                
                Button {
                    withAnimation { listDisplay.toggle() }
                } label: {
                    Image(systemName: listDisplay.systemImage)
                        .font(.title2)
                }
                .foregroundStyle(.primary)
            }
            .padding(.bottom, C.gridPadding)
            
            Divider()
            
            if let queue = player.queue {
                ScrollView { ScrollViewReader { value in
                    LazyVStack(spacing: 0) {
                        ForEach(queue.restOfQueue.indices, id: \.self) { index in
                            let song = queue.restOfQueue[index]
                            
                            QueueListButton(song: song, queueIndex: index, displayMode: $listDisplay) {
                                withAnimation {
                                    value.scrollTo(0)
                                }
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
}

#Preview {
    QueueList()
}
