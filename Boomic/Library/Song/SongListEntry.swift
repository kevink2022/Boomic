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
    let showTrackNumber: Bool
    
    init(
        song: Song
        , showAlbumArt: Bool = true
        , showArtist: Bool = true
        , showTrackNumber: Bool = false
    ) {
        self.song = song
        self.showAlbumArt = showAlbumArt
        self.showArtist = showArtist
        self.showTrackNumber = showTrackNumber
    }
    
    
    var body: some View {
        HStack {
            
            if showAlbumArt {
                Image("boomic_logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerSize: CGSize(
                        width: C.smallAlbumCornerRadius,
                        height: C.smallAlbumCornerRadius
                    )))
                    .frame(height: C.smallAlbumFrame)
            }
            
            if showTrackNumber {
                Text("\(song.trackNumber.map { String($0) } ?? "")")
                    .font(F.trackNumber)
                    .frame(minWidth: 22, alignment: .leading)

            }
            
            VStack(alignment: .leading) {
                Text(song.label)
                    .font(F.body)
                    .lineLimit(1)
                
                if showArtist, let artist = song.artistName {
                    Text(artist)
                        .font(F.listDuration)
                        .lineLimit(1)
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
    SongListEntry(song: previewSong(), showTrackNumber: true)
}
