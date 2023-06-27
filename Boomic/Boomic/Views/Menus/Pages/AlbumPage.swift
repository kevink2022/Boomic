//
//  AlbumPage.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/25/23.
//

import SwiftUI

struct AlbumPage: View
{
    @EnvironmentObject var manager : BoomicManager
    let album : Album
    
    var body: some View
    {
        VStack
        {
            List
            {
                AlbumHeader(album: album)
                
                ForEach(album.songs.indices)
                {
                    index in let song = album.songs[index]
                    
                    Button
                    {
                        manager.selectSong(queue: album.songs, queueIndex: index)
                        
                        if manager.showQueueSheet == true { manager.showQueueSheet = false }
                        else { manager.showCurrentSongSheet = true }
                    }
                    label:
                    {
                        SongEntry(song: song)
                    }
                }
            }
            .listStyle(.inset)
        }
    }
}
//
//struct AlbumPage_Previews: PreviewProvider {
//    static var previews: some View {
//        AlbumPage()
//    }
//}
