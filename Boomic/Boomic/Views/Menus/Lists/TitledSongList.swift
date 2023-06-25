//
//  SongListView.swift
//  Boomic
//
//  Created by Kevin Kelly on 11/2/22.
//

import SwiftUI

struct TitledSongList<Content: View> : View
{
    @EnvironmentObject var manager : BoomicManager
    let songs : [Song]
    var content : () -> Content
    
    
    var body: some View
    {
        VStack
        {
            List
            {
                content()
                
                ForEach(songs.indices)
                {
                    index in let song = songs[index]
                    
                    Button
                    {
                        manager.selectSong(queue: songs, queueIndex: index)
                        
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

//struct TitledSongList_Previews: PreviewProvider
//{
//    static var previews: some View
//    {
//        SongList(queue: manager.songs)
//            .environmentObject(BoomicManager())
//        SongListView(songs: manager.songs)
//            .environmentObject(BoomicManager())
//            .preferredColorScheme(.dark)
//    }
//}
