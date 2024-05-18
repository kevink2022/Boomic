// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Models

public protocol MediaFileInterface {
    var libraryDirectory: URL { get }
    
    func newSongs(existing songs: [Song]) async throws -> [Song]
}

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

public final class LocalMediaFileInterface: MediaFileInterface {
    
    public let libraryDirectory: URL
    private let fileManager: FileManager
    
    public init(
        libraryDirectory: URL = URL.documentsDirectory
        , fileManager: FileManager = FileManager()
    ) {
        self.libraryDirectory = libraryDirectory
        self.fileManager = fileManager
    }
    
    public func newSongs(existing songs: [Song]) async throws -> [Song] {
        
        let existingFiles = songs.compactMap { song in
            if case .local(let url) = song.source {
                return url
            }
            return nil
        }
        
        let newFiles = try newFiles(at: libraryDirectory, known: existingFiles)

        let newSongs = newFiles.map { file in
            let internalParser = AudioToolboxParser(file: file)
            let externalParser = DirectoryParser(file: file)
            
            let albumArt: MediaArt? = {
                if let hash = internalParser.embeddedHash { return .embedded(url: file, hash: hash) }
                if let art = externalParser.albumArt { return .local(url: art) }
                return nil
            }()
                        
            return Song(
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

        return newSongs
    }
    
    private func newFiles(at url: URL, known files: [URL]) throws -> [URL] {
        
        guard let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.isHiddenKey])
        else { throw MediaFileInterfaceError.enumeratorInitFail(url) }
        
        return enumerator.allObjects
            .compactMap { $0 as? URL }
            .filter { Song.codecs.contains($0.pathExtension.lowercased()) }
            .filter { !files.contains($0) }
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

