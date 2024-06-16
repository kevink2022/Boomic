//
//  File.swift
//  
//
//  Created by Kevin Kelly on 6/14/24.
//

import Foundation
import Domain
import Models

public final class DeleteAssertion: DeleteAssertable {

    struct Data: Codable, Equatable {
        let id: UUID
        let model: AssertionModel
        let label: String
        let path: AppPath?
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.id == rhs.id && lhs.model == rhs.model
        }
    }
    
    private init(
        id: UUID
        , model: AssertionModel
        , label: String
        , path: AppPath? = nil
    ) {
        self.data = DeleteAssertion.Data(
            id: id
            , model: model
            , label: label
            , path: path
        )
    }
    
    let data: DeleteAssertion.Data
    public var id: UUID { data.id }
    public var model: AssertionModel { data.model }
    public var label: String { data.label }
    public var path: AppPath? { data.path }
    
    public var code: AssertionCode { .delete(self) }
    
    public func willModify(_ basis: DataBasis) -> Bool {
        switch model {
        case .song: return basis.songMap[id] != nil
        case .album: return basis.albumMap[id] != nil
        case .artist: return basis.artistMap[id] != nil
        }
    }
    
    public static func == (lhs: DeleteAssertion, rhs: DeleteAssertion) -> Bool {
        lhs.data == rhs.data
    }
    
    public convenience init(_ song: Song) {
        var path: AppPath? = nil
        
        if case let .local(songPath) = song.source {
            path = songPath
        }
        
        self.init(
            id: song.id
            , model: .song
            , label: song.label
            , path: path
        )
    }
    
    public convenience init(_ album: Album) {
        self.init(
            id: album.id
            , model: .album
            , label: album.title
        )
    }
    
    public convenience init(_ artist: Artist) {
        self.init(
            id: artist.id
            , model: .artist
            , label: artist.name
        )
    }
}
