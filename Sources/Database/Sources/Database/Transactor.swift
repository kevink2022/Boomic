//
//  File.swift
//  
//
//  Created by Kevin Kelly on 4/23/24.
//

import Foundation
import Models

public final class Transactor {
    
    public init() {}
    
    public func addSongs(_ songs: [Song], to basis: DataBasis) async -> DataBasis {
        let resolver = BasisResolver(currentBasis: basis)
        return await resolver.addSongs(songs)
    }
}
