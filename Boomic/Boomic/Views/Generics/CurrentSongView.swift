//
//  CurrentSongView.swift
//  Boomic
//
//  Created by Kevin Kelly on 12/11/22.
//

import SwiftUI

struct CurrentSongView: View
{
    @EnvironmentObject var manager : BoomicManager
    let song : Song
    
    var body: some View
    {
        switch manager.library.settings.songGUI
        {
        case .classic: ClassicSongView(song: song)
        case .gesture: Gesture_GUI(song: song)
        }
    }
}

struct CurrentSongView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentSongView(song: .standard)
    }
}
