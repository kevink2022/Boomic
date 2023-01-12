//
//  Artist.swift
//  Boomic
//
//  Created by Kevin Kelly on 11/3/22.
//

import Foundation

class Artist : Identifiable, Codable
{
    var name : String
    var id : String { name }
    
    var songs : [Song] = []
    var albums : [Album] = []
 
    init(name: String)
    {
        self.name = name
    }
}


extension Artist
{
    static let ratatat = Artist(name: "Ratatat")
    
    static let unknown = Artist(name: "Unknown Artist")
    
    func addSong(_ song: Song)
    {
        self.songs.append(song)
        song.artist = self
    }
}
