//
//  RepeatButton.swift
//  Boomic
//
//  Created by Kevin Kelly on 12/11/22.
//

import SwiftUI

struct RepeatButton: View
{
    @EnvironmentObject var manager : BoomicManager

    var body: some View
    {
        Button
        {
            manager.toggleRepeat()
        }
        label:
        {
            Image(repeatLabel())
                .resizable()
                .foregroundColor(.primary)
        }
    }
    
    typealias C = ViewConstants.Classic_GUI.Subviews.ClassicQueueControls

    
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

struct RepeatButton_Previews: PreviewProvider {
    static var previews: some View {
        RepeatButton()
    }
}
