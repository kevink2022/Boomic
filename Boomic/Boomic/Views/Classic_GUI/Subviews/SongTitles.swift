//
//  SongTitles.swift
//  Boomic
//
//  Created by Kevin Kelly on 11/2/22.
//

import SwiftUI

struct SongTitles: View
{
    let song : Song
    
    var body: some View
    {
        VStack(alignment: .leading)
        {
            Text(song.titleLabel)
                .font(F.title)
                .lineLimit(C.lineLimit)
            
            Text(song.albumLabel)
                .font(F.album)
                .lineLimit(C.lineLimit)
            
            Text(song.artistLabel)
                .font(F.artist)
                .lineLimit(C.lineLimit)
        }
        .padding(.horizontal)
    }
    
    typealias F = ViewConstants.Classic_GUI.Fonts
    typealias C = ViewConstants.Classic_GUI.Subviews.ClassicTitles
    typealias P = ViewConstants.Placeholders.Unknown
}

//struct ClassicTitles_Previews: PreviewProvider {
//    static var previews: some View {
//        SongTitles(song: Song.standard)
//    }
//}
