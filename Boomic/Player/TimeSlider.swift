//
//  TimeSlider.swift
//  Boomic
//
//  Created by Kevin Kelly on 4/7/24.
//

import SwiftUI

struct TimeSlider: View {
    @Environment(\.player) private var player
    @State var progress: CGFloat = 0
    @State var barOffset: CGFloat = 0
    @State var dragging: Bool = false
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack(alignment: .bottomLeading) {
                    Rectangle()
                        .opacity(0.3)
                    Rectangle()
                        .frame(width: (geometry.size.width * (progress + barOffset)))
                }
                .gesture(DragGesture()
                    .onChanged { value in
                        dragging = true
                        barOffset = value.translation.width / geometry.size.width
                    }
                    .onEnded { value in
                        progress += barOffset
                        seek(to: progress)
                        barOffset = 0
                        dragging = false
                    }
                )
            }
            .frame(height: 10)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)))
            
            HStack {
                Text(timePassed.formatted)
                    .font(F.trackNumber)
                
                Spacer()
                
                Text(timeRemaining.formatted)
                    .font(F.trackNumber)
            }
        }
        .onChange(of: player.time) {
            if !dragging { updateSongProgress() }
        }
    }
    
    private func updateSongProgress() {
        progress = player.time / songDuration
    }
    
    private func seek(to progress: Double) {
        player.seek(to: progress * songDuration)
    }
    
    private var songDuration: TimeInterval { (player.song?.duration ?? player.time) }
    
    private var timePassed: TimeInterval { 
        if !dragging {
            return player.time
        } else {
            return songDuration * (progress + barOffset)
        }
    }
    
    private var timeRemaining: TimeInterval { 
        if !dragging {
            return (player.song?.duration ?? player.time) - player.time
        } else {
            return songDuration * (1 - (progress + barOffset))
        }
    }
       
    private typealias C = ViewConstants
    private typealias F = ViewConstants.Fonts
}

#Preview {
    TimeSlider()
        .environment(previewPlayerWithSong())
}
