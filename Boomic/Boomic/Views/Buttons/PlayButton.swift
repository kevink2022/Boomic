//
//  PlayButton.swift
//  Boomic
//
//  Created by Kevin Kelly on 12/11/22.
//

import SwiftUI

struct PlayButton: View
{
    @EnvironmentObject var manager : BoomicManager
    
    var body: some View
    {
        Button
        {
            manager.togglePlayback()
        }
        label:
        {
            Image(systemName: manager.isPlaying ? C.pauseSF : C.playSF)
                .resizable()
                .foregroundColor(.primary)
        }
        .disabled(!manager.songExists)
    }
    
    typealias C = ViewConstants.ClassicMediaControls
}

struct PlayButton_Previews: PreviewProvider {
    static var previews: some View {
        PlayButton()
    }
}
