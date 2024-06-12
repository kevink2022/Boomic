//
//  SongGrid.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/10/24.
//

import SwiftUI

import Models

private typealias C = ViewConstants
private typealias F = ViewConstants.Fonts

struct SongGrid: View {
    @Environment(\.player) private var player
    
    let songs: [Song]
    
    let key: String?
    let config: GridListConfiguration
    let header: GridListHeader
    let title: String
    let titleFont: Font
    let queueName: String?
    let showTrackNumber: Bool
    
    init(
        songs: [Song]
        , key: String? = nil
        , config: GridListConfiguration = .songStandard
        , header: GridListHeader = .standard
        , title: String = "Songs"
        , titleFont: Font = F.sectionTitle
        , queueName: String? = nil
        , showTrackNumber: Bool = false
    ) {
        self.songs = songs
        self.key = key
        self.config = config
        self.header = header
        self.title = title
        self.titleFont = titleFont
        self.queueName = queueName
        self.showTrackNumber = showTrackNumber
    }
    
    func trackNumber(_ song: Song) -> String? {
        if showTrackNumber, let number = song.trackNumber {
            return "\(number)"
        }
        
        return nil
    }
    
    var body: some View {
        GridList(
            key: key
            , config: config
            , header: header
            , title: title
            , titleFont: titleFont
            , entries: songs.map({ song in
                GridListEntry(
                    label: song.label
                    , subLabel: song.artistName
                    , listHeader: trackNumber(song)
                    , listFooter: song.duration.formatted
                    , action: { player.setSong(song, context: songs, queueName: queueName ?? "Songs") }
                    , icon: {
                        MediaArtView(song.art, cornerRadius: C.albumCornerRadius)
                    }
                    , menu: {
                        SongMenu(song: song)
                    }
                )
            })
        )
    }
}

extension GridListConfiguration {
    static let songStandard = GridListConfiguration(
        key: "songStandard"
        , columnCount: GridListConfiguration.smallIconListCount
    )
    
    static let songAlbumStandard = GridListConfiguration(
        key: "songAlbumStandard"
        , columnCount: GridListConfiguration.largeListCount
    )
}



//#Preview {
//    SongGrid()
//}
