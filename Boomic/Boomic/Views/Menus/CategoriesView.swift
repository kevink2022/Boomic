//
//  CategoriesaView.swift
//  Boomic
//
//  Created by Kevin Kelly on 11/10/22.
//

import SwiftUI

struct CategoriesView: View
{
    @EnvironmentObject var manager : BoomicManager
    
    var body: some View
    {
        VStack
        {
            
            NavigationStack
            {
                VStack(alignment: .leading)
                {
                    HStack
                    {
                        Text("Boomic Music")
                            .font(.system(.largeTitle, design: .default, weight: .heavy))
                            .padding()
                        
                        Spacer()
                        
                        NavigationLink
                        {
                            SettingsView()
                        }
                    label:
                        {
                            Image(.systemName("gearshape"))
                                .font(.title)
                                .foregroundColor(.primary)
                                .padding(.horizontal)
                        }
                    }
                    
                    GridMenu
                    {
                        NavigationLink
                        {
                            
                        }
                    label:
                        {
                            CategoryEntry(category: .playlists)
                        }
                        
                        NavigationLink
                        {
                            SongList(songs: manager.library.songs)
                        }
                    label:
                        {
                            CategoryEntry(category: .songs)
                        }
                        
                        NavigationLink
                        {
                            AlbumList(albums: manager.library.albums)
                        }
                    label:
                        {
                            CategoryEntry(category: .albums)
                        }
                        
                        NavigationLink
                        {
                            ArtistList()
                        }
                    label:
                        {
                            CategoryEntry(category: .artists)
                        }
                    }
                }
            }
            
            if let song = manager.currentSong {
                Button {manager.showCurrentSongSheet = true }
            label: { CurrentSongBar(song: song) }
            }
        }
    }
}

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView()
            .environmentObject(BoomicManager())
    }
}
