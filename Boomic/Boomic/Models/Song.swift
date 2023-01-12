//
//  Song.swift
//  Boomic
//
//  Created by Kevin Kelly on 11/1/22.
//

import Foundation

class Song : Identifiable, Codable
{
    var source : URL
    var id : URL { source }
    
    var title : String?
    var artistName : String?
    var albumTitle : String?
    var trackNo : Int?
    var duration : Double?
    
    var album: Album? = nil
    var artist: Artist? = nil
    var albumCover : ImageSource? = nil
    
    // MARK: Calculated
    var filename : String { self.source.relativeString.replacingOccurrences(of: "%20", with: " ") }
    
    var titleLabel : String { self.title ?? self.filename }
    var albumLabel : String { self.album?.title ?? self.albumTitle ?? ViewConstants.Placeholders.Unknown.album }
    var artistLabel : String { self.artist?.name ?? self.artistName ?? ViewConstants.Placeholders.Unknown.artist }
    
    init(source: URL, songTitle: String? = nil, artistName: String? = nil, albumTitle: String? = nil, trackNo: Int? = nil)
    {
        self.source = source
        self.title = songTitle
        self.artistName = artistName
        self.albumTitle = albumTitle
        self.trackNo = trackNo
        self.album = nil
        self.artist = nil
    }
}

// MARK: Methods
extension Song
{
    convenience init(source: URL, tags dict: Dictionary<String,Any>)
    {
        self.init(
            source: source,
            songTitle: dict["title"] as? String,
            artistName: dict["artist"] as? String,
            albumTitle: dict["album"] as? String,
            trackNo: Song.trackNoFromString( dict["track number"] as? String )
        )
        
        // idk why i won't let me do this in the init
        self.duration = dict["approximate duration in seconds"] as? Double
    }
    
    static func trackNoFromString(_ str: String?) -> Int?
    {
        if let str = str
        {
            if str.contains("/")
            {
                return Int(str.split(separator: "/")[0])
            }
            else
            {
                return Int(str)
            }
        }
        
        return nil
    }
}

// MARK: Static
extension Song
{
    static let standard = Song(
        source: URL.documentsDirectory,
        songTitle: "Abrasive",
        artistName: "Ratatat",
        albumTitle: "Magnifique",
        trackNo: 4
    )
    
    // Since Each song needs a source
    static let unknown = Song(
        source: URL.documentsDirectory,
        songTitle: "",
        artistName: "Unknown Artist",
        albumTitle: "Unknown Album",
        trackNo: 0
    )
}
