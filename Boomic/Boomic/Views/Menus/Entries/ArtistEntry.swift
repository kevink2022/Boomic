//
//  ArtistEntry.swift
//  Boomic
//
//  Created by Kevin Kelly on 11/14/22.
//

import SwiftUI

struct ArtistEntry: View
{
    let artist: Artist
    
    var body: some View
    {
        VStack(alignment: .center)
        {
            Image(.asset("boomic_logo"))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .mask(Circle())
            
            Text(artist.name)
                .font(F.title)
                .lineLimit(1)
        }
        .foregroundColor(.primary)
    }
    
    typealias F = ViewConstants.Menus.Fonts
}

struct ArtistListItem_Previews: PreviewProvider {
    static var previews: some View {
        ArtistEntry(artist: Artist.ratatat)
    }
}
