//
//  File.swift
//  
//
//  Created by Kevin Kelly on 5/19/24.
//

import Foundation
import Domain
import Models

extension BasisResolver {
    private func updatedTagsInUse(from tagSets: [[Set<Tag>]]) -> Set<Tag> {
        return tagSets.reduce(into: Set<Tag>()) { finalSet, tagSetArray in
            finalSet.formUnion(tagSetArray.reduce(into: Set<Tag>(), { arraySet, tags in
                arraySet.formUnion(tags)
            }))
        }
    }
    
    public func apply(transaction: LibraryTransaction, to basis: DataBasis? = nil) async -> DataBasis {
        
        let assertions = transaction.assertions
        
        var basis = basis ?? currentBasis
        
        basis = await applyDelete(assertions, to: basis)
        basis = await applyUpdate(assertions, to: basis)
        basis = await applyAdd(assertions, to: basis)
        
        let mappedBasis = basis
        /// TODO: create 'SortedSets' that are ordered array sets, then maintain along with basis
        async let updatedAllSongs_await = { mappedBasis.songMap.values.sorted{ Song.alphabeticalSort($0, $1) } }()
        async let updatedAllAlbums_await = { mappedBasis.albumMap.values.sorted{ Album.alphabeticalSort($0, $1) } }()
        async let updatedAllArtists_await = { mappedBasis.artistMap.values.sorted{ Artist.alphabeticalSort($0, $1) } }()
        async let updatedAllTaglists_await = { mappedBasis.taglistMap.values.sorted{ Taglist.alphabeticalSort($0, $1) } }()
//        async let updatedTagsInUse_await = { updatedTagsInUse(from: [mappedBasis.allSongs.map{ $0.tags }]) }

        let (
            updatedAllSongs, updatedAllAlbums, updatedAllArtists, updatedAllTaglists
        ) = await (
            updatedAllSongs_await, updatedAllAlbums_await, updatedAllArtists_await, updatedAllTaglists_await
        )
        
        let finalBasis = DataBasis(
            current: mappedBasis
            , allSongs: updatedAllSongs
            , allAlbums: updatedAllAlbums
            , allArtists: updatedAllArtists
            , allTaglists: updatedAllTaglists
        )
        
        return finalBasis
    }
    
    
    private func applyAdd(_ assertions: KeySet<Assertion>, to basis: DataBasis) async -> DataBasis {
        let adds = assertions.filter { $0.operation == .add }
        guard adds.count > 0 else { return basis }
        
        var songMap = basis.songMap
        var albumMap = basis.albumMap
        var artistMap = basis.artistMap
        var taglistMap = basis.taglistMap
        
        adds.forEach { add in
            switch add.model {
            case .song:
                if let model = add.data as? Song {
                    songMap[model.id] = model
                }
            case .album:
                if let model = add.data as? Album {
                    albumMap[model.id] = model
                }
            case .artist:
                if let model = add.data as? Artist {
                    artistMap[model.id] = model
                }
            case .taglist:
                if let model = add.data as? Taglist {
                    taglistMap[model.id] = model
                }
            }
        }
        
        return DataBasis(
            current: basis
            , songMap: songMap
            , albumMap: albumMap
            , artistMap: artistMap
            , taglistMap: taglistMap
        )
    }
    
    private func applyUpdate(_ assertions: KeySet<Assertion>, to basis: DataBasis) async -> DataBasis {
        let updates = assertions.filter { $0.operation == .update }
        guard updates.count > 0 else { return basis }
        
        var songMap = basis.songMap
        var albumMap = basis.albumMap
        var artistMap = basis.artistMap
        var taglistMap = basis.taglistMap
        
        updates.forEach { update in
            switch update.model {
            case .song:
                if let update = update.data as? SongUpdate {
                    let original = songMap[update.id]
                    songMap[update.id] = original?.apply(update: update)
                }
            case .album:
                if let update = update.data as? AlbumUpdate {
                    let original = albumMap[update.id]
                    albumMap[update.id] = original?.apply(update: update)
                }
            case .artist:
                if let update = update.data as? ArtistUpdate {
                    let original = artistMap[update.id]
                    artistMap[update.id] = original?.apply(update: update)
                }
            case .taglist:
                if let update = update.data as? TaglistUpdate {
                    let original = taglistMap[update.id]
                    taglistMap[update.id] = original?.apply(update: update)
                }
            }
        }
        
        return DataBasis(
            current: basis
            , songMap: songMap
            , albumMap: albumMap
            , artistMap: artistMap
            , taglistMap: taglistMap
        )
    }
    
    private func applyDelete(_ assertions: KeySet<Assertion>, to basis: DataBasis) async -> DataBasis {
        let deletes = assertions.filter { $0.operation == .delete }
        guard deletes.count > 0 else { return basis }

        var songMap = basis.songMap
        var albumMap = basis.albumMap
        var artistMap = basis.artistMap
        var taglistMap = basis.taglistMap
        
        deletes.forEach {
            guard let delete = $0.data as? DeleteAssertion else { return }
            
            switch delete.model {
            case .song:
                songMap[delete.id] = nil
            case .album:
                albumMap[delete.id] = nil
            case .artist:
                artistMap[delete.id] = nil
            case .taglist:
                taglistMap[delete.id] = nil
            }
        }
        
        return DataBasis(
            current: basis
            , songMap: songMap
            , albumMap: albumMap
            , artistMap: artistMap
            , taglistMap: taglistMap
        )
    }
    
    
}
