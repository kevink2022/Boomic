//
//  SongContextMenu.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/25/23.
//

import SwiftUI

struct SongContextMenu: View
{
    let song : Song
    
    var body: some View
    {
        // Like
        Button
        {
            song.liked.toggle()
        } label: {
            if song.liked {
                Label("Unlike", systemImage: "heart.fill")
            } else {
                Label("Like", systemImage:   "heart")
            }
        }
        
        Divider()
        
        // Add to queue
        Button
        {
            //
        } label: {
            Label("Add to Queue", systemImage: "text.line.first.and.arrowtriangle.forward")
        }
        
        // Add to playlist
        Button
        {
            //
        } label: {
            Label("Add to Playlist", systemImage: "text.badge.plus")
        }
        
        Divider()
        
        // Artist
        if let artist = song.artist
        {
            NavigationLink
            {
                SongList(songs: artist.songs)
            } label: {
                Label("View Artist", systemImage: "person.crop.circle")
            }
        }
        
        // Album
        if let album = song.album
        {
            NavigationLink
            {
                SongList(songs: album.songs)
            } label: {
                Label("View Album", systemImage: "globe")
            }
        }
        
        Divider()
        
        // Tags
        Button
        {
            //
        } label: {
            Label("View Tags", systemImage: "doc")
        }
        
        // File Location
        Button
        {
            //
        } label: {
            Label("View in Files", systemImage: "folder")
        }
        
        
    }
}
//
//struct SongContextMenu_Previews: PreviewProvider {
//    static var previews: some View {
//        SongContextMenu(song)
//    }
//}
