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

public final class Query {
    private var cancellables: Set<AnyCancellable> = []
    private var basis: DataBasis = DataBasis.empty
    
    public var songs: [Song] = []
    public var albums: [Album] = []
    public var artists: [Artist] = []
    
    private var songIDs: [UUID] = []
    private var albumIDs: [UUID] = []
    private var artistIDs: [UUID] = []
    
    public init(
        basisPublisher: CurrentValueSubject<DataBasis, Never>
    ) {
        basisPublisher
            .sink(receiveValue: { [weak self] basis in
                guard let self = self else { return }
                self.basis = basis
                self.refresh()
            })
            .store(in: &cancellables)
        
        basis = basisPublisher.value
    }
    
    private func refresh() {
        self.songs = self.songIDs.compactMap({ basis.songMap[$0] })
        self.albums = self.songIDs.compactMap({ basis.albumMap[$0] })
        self.artists = self.songIDs.compactMap({ basis.artistMap[$0] })
    }
}

extension Query {
    public func forAlbum(_ album: Album) {
        songIDs = album.songs
        albumIDs = [album.id]
        artistIDs = album.artists
    }

}
