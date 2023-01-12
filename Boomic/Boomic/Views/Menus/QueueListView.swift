//
//  QueueListView.swift
//  Boomic
//
//  Created by Kevin Kelly on 11/20/22.
//

import SwiftUI

struct QueueListView: View
{
    @EnvironmentObject var manager : BoomicManager
    
    var body: some View
    {
        VStack
        {
            List
            {
                ForEach(manager.queue.indices)
                {
                    index in let song = manager.queue[index]
                    
                    Button
                    {
                        manager.queueSelectSong(index: index)
                    }
                    label:
                    {
                        ZStack
                        {
                            SongListItem(song: song, selected: manager.currentSongIndex! == index ? true : false)
                        }
                    }
                }
            }
            .listStyle(.inset)
        }
    }
}

//struct QueueListView_Previews: PreviewProvider {
//    static var previews: some View {
//        QueueListView()
//
//    }
//}
