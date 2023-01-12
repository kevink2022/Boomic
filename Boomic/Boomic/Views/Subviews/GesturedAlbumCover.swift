//
//  GesturedAlbumCover.swift
//  Boomic
//
//  Created by Kevin Kelly on 12/2/22.
//

import SwiftUI

struct GesturedAlbumCover: View
{
    @EnvironmentObject var manager : BoomicManager
    @State var offset = CGSize.zero
    @State var scale = CGSize(width: 1, height: 1)
    
    var body: some View
    {
        // TODO: - why does the last song album's angle go to zero for a second?
        let drag = DragGesture(minimumDistance: C.minimumGesture)
            .onChanged { value in
                offset.width = value.translation.width
                print(offset.width)
            }
            .onEnded { value in
                /// Setting offset to negative and and changing song at the same time puts
                /// the new current album in the place of the where the desired album was,
                /// but the neighboring album to disapear so it doesn't really work
                /// - with the animation, the disapeaerring album is fine
                if offset.width > 100
                {
                    offset.width = -offset.width
                    manager.toLastSong()
                    withAnimation(.easeOut(duration: C.animationDuration)) { offset.width = 0 }
                }
                else if offset.width < -100
                {
                    offset.width = -offset.width
                    manager.toNextSong()
                    withAnimation(.easeOut(duration: C.animationDuration)) { offset.width = 0 }
                }
                else
                {
                    withAnimation(.easeOut(duration: C.animationDuration)) { offset.width = 0 }
                }
            }
        
        ZStack
        {
            if lastSongOffset.width > -C.offscreenOffset
            {
                StaticAlbumCover(image: manager.lastSong?.albumCover)
                    .rotation3DEffect(
                        lastSongAngle,
                        axis: (x: 0.0, y: -1.0, z: 0.0),
                        anchor: .trailing)
                    .offset(lastSongOffset)
            }
            
            if nextSongOffset.width < C.offscreenOffset
            {
                StaticAlbumCover(image: manager.nextSong?.albumCover)
                    .rotation3DEffect(
                        nextSongAngle,
                        axis: (x: 0.0, y: 1.0, z: 0.0),
                        anchor: .leading)
                    .offset(nextSongOffset)
            }
            
            StaticAlbumCover(image: manager.currentSong?.albumCover)
                .rotation3DEffect(
                    currentSongAngle,
                    axis: currentSongAxis,
                    anchor: currentSongAnchor)
                .offset(currentSongOffset)
                .gesture(drag)
        }
    }
    
    var lastSongOffset : CGSize { CGSize(width: offset.width - C.offscreenOffset, height: 0) }
    var lastSongAngle : Angle { Angle(degrees: -lastSongOffset.width / C.angleDivider ) }
    
    var nextSongOffset : CGSize { CGSize(width: offset.width + C.offscreenOffset, height: 0) }
    var nextSongAngle : Angle { Angle(degrees: nextSongOffset.width / C.angleDivider ) }
    
    var currentSongOffset : CGSize { CGSize(width: offset.width, height: 0) }
    var currentSongAngle : Angle { Angle(degrees: abs(Double(offset.width)) / C.angleDivider ) }
    var currentSongAnchor : UnitPoint { (offset.width >= 0 ? .leading : .trailing) }
    var currentSongAxis : (x: CGFloat, y: CGFloat, z: CGFloat) { (x: 0.0, y: (offset.width >= 0 ? 1.0 : -1.0), z: 0.0) }
    
    typealias C = ViewConstants.Subviews.GesturedAlbumCover
}

extension ViewConstants.Subviews
{
    struct GesturedAlbumCover
    {
        static let minimumGesture = CGFloat(50)
        static let offscreenOffset = CGFloat(400)
        static let angleDivider = Double(6.0)
        static let animationDuration = Double(0.2)
        static let gestureThreshold : Int = 100
    }
}

//struct GesturedAlbumCover_Previews: PreviewProvider {
//    static var previews: some View {
//        GesturedAlbumCover()
//    }
//}
