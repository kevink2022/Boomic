//
//  SongListEntry.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/16/24.
//

import SwiftUI
import Models

private typealias C = ViewConstants
private typealias F = ViewConstants.Fonts

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
                MediaArtView(song.art, cornerRadius: C.smallAlbumCornerRadius)
                    .frame(height: C.smallAlbumFrame)
            }
            
            if showTrackNumber {
                Text("\(song.trackNumber.map { String($0) } ?? "")")
                    .font(F.trackNumber)
                    .frame(minWidth: C.songTrackNumberWidth, alignment: .leading)

            }
            
            VStack(alignment: .leading) {
                Text(song.label)
                    .font(F.listEntryTitle)
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
        }
        .frame(minHeight: C.songListEntryMinHeight)
    }
}

#Preview {
    SongListEntry(song: PreviewMocks.shared.previewSong(), showTrackNumber: true)
}
