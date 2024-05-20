// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Models

public enum MediaFileInterfaceError: LocalizedError, Equatable {
    case enumeratorInitFail(URL)
    
    public var errorDescription: String? {
        switch self {
        case .enumeratorInitFail(let url): return "An enumerator could not be initialized at the library URL: \(url)"
        }
    }
    
    public static func == (lhs: MediaFileInterfaceError, rhs: MediaFileInterfaceError) -> Bool {
        switch (lhs, rhs) {
        case (.enumeratorInitFail(let lhs), .enumeratorInitFail(let rhs)):
            return String(describing: lhs) == String(describing: rhs)
        }
    }
}

extension Song {
    public convenience init(from file: URL) {
        let internalParser = AudioToolboxParser(file: file)
        let externalParser = DirectoryParser(file: file)
        
        let albumArt: MediaArt? = {
            if let hash = internalParser.embeddedHash { return .embedded(url: file, hash: hash) }
            if let art = externalParser.albumArt { return .local(url: art) }
            return nil
        }()
        
        self.init(
            id: UUID()
            , source: .local(url: file)
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

