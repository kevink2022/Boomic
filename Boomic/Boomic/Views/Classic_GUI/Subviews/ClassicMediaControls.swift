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
                withAnimation { manager.toLastSong() }
            }
            label:
            {
                Image(systemName: C.lastSongSF)
            }
            
            Spacer()
            
            Button
            {
                manager.togglePlayback()
            }
            label:
            {
                Image(systemName: manager.isPlaying ? C.pauseSF : C.playSF)
            }
            .disabled(!manager.songExists)
            
            Spacer()
            
            Button
            {
                withAnimation { manager.toNextSong() }
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
    
    typealias C = ViewConstants.Classic_GUI.Subviews.ClassicMediaControls
    typealias F = ViewConstants.Classic_GUI.Fonts
}

struct ClassicMediaControls_Previews: PreviewProvider {
    static var previews: some View {
        ClassicMediaControls()
            .environmentObject(BoomicManager())
    }
}
