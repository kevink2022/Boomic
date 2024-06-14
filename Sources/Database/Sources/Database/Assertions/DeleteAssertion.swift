//
//  File.swift
//  
//
//  Created by Kevin Kelly on 6/14/24.
//

import Foundation
import Models

public final class DeleteAssertion: DeleteAssertable {

    struct Data: Codable, Equatable {
        let id: UUID
        let model: AssertionModel
        let label: String
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.id == rhs.id && lhs.model == rhs.model
        }
    }
    
    private init(
        id: UUID
        , model: AssertionModel
        , label: String
    ) {
        self.data = DeleteAssertion.Data(
            id: id
            , model: model
            , label: label
        )
    }
    
    let data: DeleteAssertion.Data
    public var id: UUID { data.id }
    public var model: AssertionModel { data.model }
    public var label: String { data.label }
    
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
        self.init(
            id: song.id
            , model: .song
            , label: song.label
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
