//
//  SongListEntry.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/16/24.
//

import SwiftUI
import Models

struct SongListEntry: View {
    let song: Song
    let showAlbumArt: Bool
    let showArtist: Bool
    
    init(song: Song, showAlbumArt: Bool = true, showArtist: Bool = true) {
        self.song = song
        self.showAlbumArt = showAlbumArt
        self.showArtist = showArtist
    }
    
    
    var body: some View {
        HStack {
            
            if showAlbumArt {
                Image("boomic_logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerSize: CGSize(
                        width: C.albumCornerRadius,
                        height: C.albumCornerRadius
                    )))
                    .frame(height: 50)
            }
            
            VStack(alignment: .leading) {
                Text(song.label)
                    .font(F.body)
                
                if showArtist, let artist = song.artistName {
                    Text(artist)
                }
            }
            
            Spacer()
            
            Text(song.duration.formatted)
                .font(F.listDuration)
            
            Button {
                
            } label: {
                Image(systemName: "ellipsis")
            }

        }
    }
    
    private typealias C = ViewConstants
    private typealias F = ViewConstants.Fonts
}

#Preview {
    SongListEntry(song: previewSong())
}
