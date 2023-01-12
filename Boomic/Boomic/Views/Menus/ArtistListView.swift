//
//  ArtistListView.swift
//  Boomic
//
//  Created by Kevin Kelly on 11/14/22.
//

import SwiftUI

struct ArtistListView: View
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
                        SongListView(songs: artist.songs)
                    }
                    label:
                    {
                        ArtistListItem(artist: artist)
                    }
                }
            }
        }
    }
}

struct ArtistListView_Previews: PreviewProvider {
    static var previews: some View {
        ArtistListView()
    }
}
