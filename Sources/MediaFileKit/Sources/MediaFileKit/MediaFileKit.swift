// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Models

extension Song {
    public convenience init(from file: URL) {
        let internalParser = AudioToolboxParser(file: file)
        let externalParser = DirectoryParser(file: file)
        
        let albumArt: MediaArt? = {
            if let hash = internalParser.embeddedHash { return .embedded(path: AppPath(url: file), hash: hash) }
            if let art = externalParser.albumArt { return .local(path: AppPath(url: art)) }
            return nil
        }()
        
        self.init(
            id: UUID()
            , source: .local(path: AppPath(url: file))
            , duration: internalParser.duration ?? 0
            , title: internalParser.title
            , trackNumber: internalParser.trackNumber
            , discNumber: externalParser.discNumber
            , art: albumArt
            , artistName: internalParser.artist
            , albumTitle: internalParser.album
        )
    }
}

