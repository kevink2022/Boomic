//
//  SongListItem.swift
//  Boomic
//
//  Created by Kevin Kelly on 11/4/22.
//

import SwiftUI

struct SongListItem: View
{
    let song : Song
    let selected : Bool
    let namespace : Namespace.ID?
    
    init(song: Song, selected: Bool = false, namespace: Namespace.ID? = nil)
    {
        self.song = song
        self.selected = selected
        self.namespace = namespace
    }
    
    // TODO: Clean this, code is duplicated apart from namespace stuff
    var body: some View
    {
        ZStack
        {
            HStack
            {
                if let namespace = namespace
                {
                    StaticAlbumCover(image: song.albumCover)
                        .matchedGeometryEffect(id: "album_cover", in: namespace)
                    
                    VStack(alignment: .leading)
                    {
                        Text(song.title ?? song.filename)
                            .font(F.title)
                        
                        Text(song.artist?.name ?? P.Unknown.artist)
                            .font(F.artist)
                    }
                    .foregroundColor(selected ? .accentColor : .primary)
                    .matchedGeometryEffect(id: "titles", in: namespace)
                }
                else
                {
                    StaticAlbumCover(image: song.albumCover)
                    
                    VStack(alignment: .leading)
                    {
                        Text(song.title ?? song.filename)
                            .font(F.title)
                        
                        Text(song.artist?.name ?? P.Unknown.artist)
                            .font(F.artist)
                    }
                    .foregroundColor(selected ? .accentColor : .primary)
                }
                
                Spacer()
            }
        }
        .frame(height: C.height)
        .clipped()
    }
    
    typealias C = ViewConstants.Menus.SongListItem
    typealias F = ViewConstants.Menus.Fonts
    typealias P = ViewConstants.Placeholders
}

struct SongListItem_Previews: PreviewProvider {
    static var previews: some View {
        SongListItem(song: Song.standard)
    }
}
