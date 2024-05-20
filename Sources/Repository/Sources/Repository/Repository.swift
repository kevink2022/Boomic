// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Combine

import Models
import Database
import MediaFileKit

public final class Repository {
    
    public let artLoader: MediaArtLoader
    private let fileInterface: FileInterface
       
    private let queryEngine: QueryEngine
    private let transactor: BoomicTransactor
    private var dataBasis: DataBasis
    
    private var cancellables: Set<AnyCancellable> = []
    
    public init(
        fileInterface: FileInterface = FileInterface(at: URL.documentsDirectory)
        , artLoader: MediaArtLoader = MediaArtCache()
        , queryEngine: QueryEngine = QueryEngine()
        , transactor: BoomicTransactor = BoomicTransactor()
    ) {
        self.fileInterface = fileInterface
        self.artLoader = artLoader
        
        self.dataBasis = .empty
        self.queryEngine = queryEngine
        self.transactor = transactor
        
        transactor.publisher
            .sink(receiveValue: { [weak self] newBasis in
                self?.dataBasis = newBasis
            })
            .store(in: &cancellables)
    }
}

// MARK: - Queries
extension Repository {
    public func getSongs(for ids: [UUID]?) -> [Song] {
        return queryEngine.getSongs(for: ids, from: dataBasis)
    }
    
    public func getAlbums(for ids: [UUID]?) -> [Album] {
        return queryEngine.getAlbums(for: ids, from: dataBasis)
    }
    
    public func getArtists(for ids: [UUID]?) -> [Artist] {
        return queryEngine.getArtists(for: ids, from: dataBasis)
    }
}

// MARK: - Transactions
extension Repository {
    public func addSongs(_ songs: [Song]) async {
        let existingFiles = queryEngine.getSongs(for: nil, from: dataBasis).compactMap { song in
            if case .local(let url) = song.source { return url }
            return nil
        }
               
        guard let newFiles = try? fileInterface.allFiles(of: Song.codecs, excluding: Set(existingFiles)) else { return }
       
        let newSongs = newFiles.map { Song(from: $0) }
        
        await transactor.addSongs(newSongs, to: dataBasis)
    }
    
    public func updateSong(_ songUpdate: SongUpdate) async {
        await transactor.updateSong(songUpdate, on: dataBasis)
    }
    
    public func getTransactions(last count: Int? = nil) async -> [LibraryTransaction] {
        return await transactor.getTransactions(last: count)
    }
    
    public func deleteLibraryData() async {
        await transactor.deleteLibraryData()
    }
}
