//
//  ClassicMediaControls.swift
//  Boomic
//
//  Created by Kevin Kelly on 11/2/22.
//

import SwiftUI

struct ClassicMediaControls: View
{
    @EnvironmentObject var manager : BoomicManager
    
    var body: some View
    {
        HStack
        {
            Spacer()
            
            Button
            {
                withAnimation(.linear(duration: C.animationDuration)) { manager.toLastSong() }
            }
        label:
            {
                Image(systemName: C.lastSongSF)
            }
            
            Spacer()
            
            withAnimation(.linear(duration: C.animationDuration)) {
                Image(systemName: manager.isPlaying ? C.pauseSF : C.playSF)
                    .onTapGesture {
                        manager.togglePlayback()
                    }
            }
            
            Spacer()
            
            Button
            {
                withAnimation(.linear(duration: C.animationDuration)) { manager.toNextSong() }
            }
            label:
            {
                Image(systemName: C.nextSongSF)
            }
            
            Spacer()
        }
        .font(F.mediaControls)
        .foregroundColor(C.color)
    }
    
    typealias C = ViewConstants.ClassicMediaControls
    typealias F = ViewConstants.Classic_GUI.Fonts
}

extension ViewConstants
{
    struct ClassicMediaControls
    {
        static let animationDuration = 0.005
        static let playSF = "play.fill"
        static let pauseSF = "pause.fill"
        static let lastSongSF = "backward.fill"
        static let nextSongSF = "forward.fill"
        static let color = Color.primary
    }
}

struct ClassicMediaControls_Previews: PreviewProvider {
    static var previews: some View {
        ClassicMediaControls()
            .environmentObject(BoomicManager())
    }
}
