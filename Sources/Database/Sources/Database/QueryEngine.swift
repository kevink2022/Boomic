//
//  File.swift
//  
//
//  Created by Kevin Kelly on 4/23/24.
//

import Foundation
import Models

final public class QueryEngine {
    
    public init() {}
    
    public func getSongs(for ids: [UUID]? = nil, from basis: DataBasis) -> [Song] {
        if let ids = ids {
            return ids.compactMap { basis.songMap[$0] }
        } else {
            return basis.allSongs
        }
    }
    
    public func getAlbums(for ids: [UUID]? = nil, from basis: DataBasis) -> [Album] {
        if let ids = ids {
            return ids.compactMap { basis.albumMap[$0] }
        } else {
            return basis.allAlbums
        }
    }
    
    public func getArtists(for ids: [UUID]? = nil, from basis: DataBasis) -> [Artist] {
        if let ids = ids {
            return ids.compactMap { basis.artistMap[$0] }
        } else {
            return basis.allArtists
        }
    }
}
