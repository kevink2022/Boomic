//
//  TrackNumberText.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/26/23.
//

import SwiftUI

struct TrackNumberText: View
{
    let song : Song
    
    var body: some View
    {
        if let trackNo = song.trackNo {
            Text(String(trackNo))
                .font(.subheadline)
                .opacity(0.6)
        } else {
            Text("•")
                .font(.subheadline)
                .opacity(0.6)
        }
    }
}

struct TrackNumberText_Previews: PreviewProvider {
    static var previews: some View {
        TrackNumberText(song: .standard)
    }
}
