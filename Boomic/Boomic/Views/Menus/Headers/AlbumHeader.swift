//
//  AlbumHeader.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/25/23.
//

import SwiftUI

struct AlbumHeader: View
{
    let album : Album
    
    var body: some View
    {
        VStack
        {
            StaticAlbumCover(image: album.albumCover)
            
            Text(album.title)
                .font(.title)
            
            if let artist = album.artist
            {
                Text(artist.name)
                    .font(.subheadline)
            }
            else if let artistName = album.artistName
            {
                Text(artistName)
                    .font(.subheadline)
            }
            else
            {
                Text("Unknown Artist")
                    .font(.subheadline)
            }
            
        }
    }
}

//struct AlbumHeader_Previews: PreviewProvider {
//    static var previews: some View {
//        AlbumHeader(album: .magnifique, body: )
//    }
//}
