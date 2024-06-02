//
//  Query.swift
//
//
//  Created by Kevin Kelly on 5/27/24.
//

import Foundation
import Combine
import SwiftUI

import Models

@Observable
public final class Query {
    private var cancellables: Set<AnyCancellable> = []
    private var basis: DataBasis = DataBasis.empty
    
    public var songs: [Song] { songIDs.compactMap { basis.songMap[$0] } }
    public var albums: [Album] { albumIDs.compactMap { basis.albumMap[$0] } }
    public var artists: [Artist] { artistIDs.compactMap { basis.artistMap[$0] } }
    
    private var songIDs: [UUID] = []
    private var albumIDs: [UUID] = []
    private var artistIDs: [UUID] = []
    
    public init() { }
    
    public func addBasis(publisher: CurrentValueSubject<DataBasis, Never>) {
        publisher
            .sink(receiveValue: { [weak self] basis in
                guard let self = self else { return }
                self.basis = basis
            })
            .store(in: &cancellables)
    }
}

extension Query {
    public func forAlbum(_ album: Album) {
        songIDs = album.songs
        albumIDs = [album.id]
        artistIDs = album.artists
    }

}
