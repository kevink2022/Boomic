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
                        CategoryView(category: .playlists)
                    }

                    NavigationLink
                    {
                        SongList(songs: manager.library.songs)
                    }
                    label:
                    {
                        CategoryView(category: .songs)
                    }

                    NavigationLink
                    {
                        AlbumList(albums: manager.library.albums)
                    }
                    label:
                    {
                        CategoryView(category: .albums)
                    }

                    NavigationLink
                    {
                        ArtistList()
                    }
                    label:
                    {
                        CategoryView(category: .artists)
                    }
                }
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
