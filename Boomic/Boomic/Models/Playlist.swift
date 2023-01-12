//
//  Playlist.swift
//  Boomic
//
//  Created by Kevin Kelly on 11/30/22.
//

import Foundation

struct Playlist : Codable
{
    var title : String
    var description : String
    var songs : [Song]
}
