//
//  CurrentSongAlbumCover.swift
//  Boomic
//
//  Created by Kevin Kelly on 12/10/22.
//

import SwiftUI

struct CurrentSongAlbumCover: View
{
    @EnvironmentObject var manager : BoomicManager
    let song : Song
    
    var body: some View
    {
        switch manager.library.settings.albumCover
        {
        case .notGestured: StaticAlbumCover(image: song.albumCover)
                .contextMenu { SongContextMenu(song: song) }
            
        case .gestured: GesturedAlbumCover()
                .contextMenu { SongContextMenu(song: song) }
        }
    }
}

//struct AlbumCover_Previews: PreviewProvider {
//    static var previews: some View {
//        CurrentSongAlbumCover()
//    }
//}
