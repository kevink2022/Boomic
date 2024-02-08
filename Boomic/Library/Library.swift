//
//  Library.swift
//  Boomic
//
//  Created by Kevin Kelly on 1/27/24.
//

import Foundation
import Models

public struct Library {
    public var songs: [Song]
    public var albums: [Album]
    public var artists: [Artist]
    //public var collections: LibraryCollection
}

enum LibraryCollectionList {
    case allSongs
}
