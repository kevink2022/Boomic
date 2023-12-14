//
//  BoomicLibrary.swift
//  Boomic
//
//  Created by Kevin Kelly on 11/2/22.
//

import Foundation

struct BoomicLibrary : Codable
{
    var songs : [Song]
    var albums : [Album]
    var artists : [Artist]
    var playlists : [Playlist]
    var settings : BoomicSettings
    
    enum SupportedFileFormats : String, CaseIterable
    {
        case flac, m4a
    }
    
    enum SupportedAlbumArtFormats : String, CaseIterable
    {
        case png, jpg, jpeg
    }
    
    static let empty = BoomicLibrary(
        songs: [],
        albums: [],
        artists: [],
        playlists: [],
        settings: BoomicSettings(
            songGUI: .classic,
            timeSlider: .classic,
            albumGesture: .notGestured,
            showArt: .show
        )
    )
}


