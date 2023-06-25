//
//  ArtistList.swift
//  Boomic
//
//  Created by Kevin Kelly on 11/14/22.
//

import SwiftUI

struct ArtistList: View
{
    @EnvironmentObject var manager : BoomicManager
    
    var body: some View
    {
        VStack
        {
            GridMenu
            {
                ForEach(manager.library.artists)
                {
                    artist in
                    
                    NavigationLink
                    {
                        SongList(songs: artist.songs)
                    }
                    label:
                    {
                        ArtistEntry(artist: artist)
                    }
                }
            }
        }
    }
}

struct ArtistList_Previews: PreviewProvider {
    static var previews: some View {
        ArtistList()
    }
}
