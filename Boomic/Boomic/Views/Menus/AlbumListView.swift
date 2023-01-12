//
//  AlbumListView.swift
//  Boomic
//
//  Created by Kevin Kelly on 11/14/22.
//

import SwiftUI

struct AlbumListView: View
{
    @EnvironmentObject var manager : BoomicManager
    let albums : [Album]
    
    var body: some View
    {
        VStack
        {
            GridMenu
            {
                ForEach(albums)
                {
                    album in
                    
                    NavigationLink
                    {
                        SongListView(songs: album.songs)
                    }
                    label:
                    {
                        AlbumListItem(album: album)
                    }
                }
            }
        }
    }
}

//struct AlbumListView_Previews: PreviewProvider {
//    static var previews: some View {
//        AlbumListView()
//            .environmentObject(BoomicManager())
//    }
//}
