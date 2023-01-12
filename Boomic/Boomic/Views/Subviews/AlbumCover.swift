//
//  AlbumCover.swift
//  Boomic
//
//  Created by Kevin Kelly on 12/10/22.
//

import SwiftUI

struct AlbumCover: View
{
    @EnvironmentObject var manager : BoomicManager
    
    var body: some View
    {
        switch manager.library.settings.albumCover
        {
        case .notGestured: StaticAlbumCover(image: manager.currentSong?.albumCover)
        case .gestured: GesturedAlbumCover()
        }
    }
}

//struct AlbumCover_Previews: PreviewProvider {
//    static var previews: some View {
//        AlbumCover()
//    }
//}
