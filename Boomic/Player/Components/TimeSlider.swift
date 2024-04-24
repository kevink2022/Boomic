//
//  TimeSlider.swift
//  Boomic
//
//  Created by Kevin Kelly on 4/7/24.
//

import SwiftUI

private typealias C = ViewConstants
private typealias F = ViewConstants.Fonts
private typealias A = ViewConstants.Animations

struct TimeSlider: View {
    @Environment(\.player) private var player
    @State var progress: CGFloat = 0
    @State var barOffset: CGFloat = 0
    @State var dragging: Bool = false
    
    private var progressPlusOffset: CGFloat { max(0, min(1, progress + barOffset)) }
       
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack(alignment: .bottomLeading) {
                    Rectangle()
                        .opacity(C.timeSliderOpacity)
                    Rectangle()
                        .frame(width: geometry.size.width * progressPlusOffset)
                }
                .gesture(DragGesture()
                    .onChanged { value in
                        withAnimation(A.timeSliderExpansion) { dragging = true }
                        barOffset = value.translation.width / geometry.size.width
                    }
                    .onEnded { value in
                        progress = progressPlusOffset
                        seek(to: progress)
                        barOffset = 0
                        Task {
                            // band-aid for progress bar showing preseek time
                            try? await Task.sleep(nanoseconds: 10_000_000)
                            withAnimation(A.timeSliderExpansion) { dragging = false }
                        }
                    }
                )
            }
            .frame(height: dragging ? C.timeSliderExpandedHeight : C.timeSliderHeight)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: C.timeSliderHeight, height: C.timeSliderHeight)))
            
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
        .task {
            updateSongProgress() // update on init
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
            return songDuration * progressPlusOffset
        }
    }
    
    private var timeRemaining: TimeInterval { 
        if !dragging {
            return (player.song?.duration ?? player.time) - player.time
        } else {
            return songDuration * (1 - progressPlusOffset)
        }
    }
}

#Preview {
    TimeSlider()
        .environment(previewPlayerWithSong())
}
