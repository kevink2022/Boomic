//
//  ClassicQueueControls.swift
//  Boomic
//
//  Created by Kevin Kelly on 11/7/22.
//

import SwiftUI

struct ClassicQueueControls: View
{
    @EnvironmentObject var manager : BoomicManager
    
    var body: some View
    {
        HStack
        {
            Spacer()
            
            Button
            {
                manager.toggleRepeat()
            }
            label:
            {
                Image(repeatLabel())
            }
            
            Spacer()
            
            Button
            {
                manager.toggleShuffle()
            }
            label:
            {
                Image(shuffleLabel())
            }
                
            Spacer()
            
            Button
            {
                withAnimation(.easeIn(duration: 0.2)) { manager.showQueueSheet.toggle() }
            }
            label:
            {
                Image(systemName: C.queueSF)
            }
            
            Spacer()
        }
        .font(F.queueControls)
        .foregroundColor(.primary)
    }
    
    typealias C = ViewConstants.Classic_GUI.Subviews.ClassicQueueControls
    typealias F = ViewConstants.Classic_GUI.Fonts
    
    func shuffleLabel() -> ImageSource
    {
        switch manager.shuffleState
        {
        case .inOrder : return .systemName(C.inOrderSF)
        case .shuffle : return .systemName(C.shuffleSF)
        }
    }
    
    func repeatLabel() -> ImageSource
    {
        switch manager.repeatState
        {
        case .dontRepeat : return .systemName(C.dontRepeatSF)
        case .repeatQueue: return .systemName(C.repeatQueueSF)
        case .repeatSong : return .systemName(C.repearSongSF)
        case .singleSong : return .systemName(C.singleSongSF)
        }
    }
}

struct ClassicQueueControls_Previews: PreviewProvider {
    static var previews: some View {
        ClassicQueueControls()
    }
}
