//
//  SongListView.swift
//  Boomic
//
//  Created by Kevin Kelly on 11/2/22.
//

import SwiftUI

struct SongListView: View
{
    @EnvironmentObject var manager : BoomicManager
    let songs : [Song]
    
    var body: some View
    {
        VStack
        {
            List
            {
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
                        SongListItem(song: song)
                    }
                }
            }
            .listStyle(.inset)
        }
    }
}

//struct SongListView_Previews: PreviewProvider
//{
//    static var previews: some View
//    {
//        SongListView(queue: manager.songs)
//            .environmentObject(BoomicManager())
//        SongListView(songs: manager.songs)
//            .environmentObject(BoomicManager())
//            .preferredColorScheme(.dark)
//    }
//}
