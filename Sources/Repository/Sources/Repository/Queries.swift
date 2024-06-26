//
//  File.swift
//  
//
//  Created by Kevin Kelly on 6/23/24.
//

import Foundation
import Models

extension Repository {
    
    public func song(_ song: Song) -> Song? {
        return basis.songMap[song.id]
    }
    
    public func songs(_ ids: [UUID]? = nil) -> [Song] {
        if let ids = ids {
            return ids.compactMap { basis.songMap[$0] }
        } else {
            return basis.allSongs
        }
    }
    
    public func album(_ album: Album) -> Album? {
        return basis.albumMap[album.id]
    }
    
    public func albums(_ ids: [UUID]? = nil) -> [Album] {
        if let ids = ids {
            return ids.compactMap { basis.albumMap[$0] }
        } else {
            return basis.allAlbums
        }
    }
    
    public func artist(_ artist: Artist) -> Artist? {
        return basis.artistMap[artist.id]
    }
    
    public func artists(_ ids: [UUID]? = nil) -> [Artist] {
        if let ids = ids {
            return ids.compactMap { basis.artistMap[$0] }
        } else {
            return basis.allArtists
        }
    }
    
    public func taglist(_ list: Taglist) -> Taglist? {
        return basis.taglistMap[list.id]
    }
    
    public func taglists(_ ids: [UUID]? = nil) -> [Taglist] {
        if let ids = ids {
            return ids.compactMap { basis.taglistMap[$0] }
        } else {
            return basis.allTaglists
        }
    }
}
