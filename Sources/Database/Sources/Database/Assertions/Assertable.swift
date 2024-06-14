//
//  File.swift
//  
//
//  Created by Kevin Kelly on 6/13/24.
//

import Foundation
import Domain
import Models

public struct Assertion: Identifiable, Codable {
    public let data: any Assertable
    public var id: UUID { data.id }
    public var operation: AssertionOperation { data.operation }
    public var model: AssertionModel { data.model }
    public var code: AssertionCode { data.code }
    
    public func willModify(_ basis: DataBasis) -> Bool {
        data.willModify(basis)
    }
    
    public init(_ data: any Assertable) {
        self.data = data
    }
    
    private init(code: AssertionCode) {
        switch code {
        case .addSong(let model): self.data = model
        case .addAlbum(let model): self.data = model
        case .addArtist(let model): self.data = model
        case .updateSong(let model): self.data = model
        case .updateAlbum(let model): self.data = model
        case .updateArtist(let model): self.data = model
        case .delete(let model): self.data = model
        }
    }
    
    public static func flatten(_ assertions: [KeySet<Assertion>]) -> KeySet<Assertion> {
        let count = assertions.count
        guard count != 0 else { return KeySet() }
        if count == 1 { return assertions.first! }
        
        let middle = count/2
        
        let left = flatten(Array(assertions.prefix(middle)))
        let right = flatten(Array(assertions.suffix(from: middle)))
    
        return union(left: left, right: right)
    }
    
    private static func union(left: KeySet<Assertion>, right: KeySet<Assertion>) -> KeySet<Assertion> {
        
        var merged = KeySet<Assertion>()
        
        left.forEach { leftAssertion in
            if let rightAssertion = right[leftAssertion] {
                merged.insert(combine(left: leftAssertion, right: rightAssertion))
            } else {
                merged.insert(leftAssertion)
            }
        }
        
        right.forEach { rightAssertion in
            if !merged.contains(rightAssertion) {
                merged.insert(rightAssertion)
            }
        }
        
        return merged
    }
    
    private static func combine(left: Assertion, right: Assertion) -> Assertion {
        guard left.id == right.id && left.model == right.model else { return left }
        
        switch left.operation {
        case .add:
            switch right.operation {
            case .add: return right     /* unexpected */
            case .update: 
                if let add = left.data as? any AddAssertable, let update = right.data as? any UpdateAssertable {
                    return Assertion(add.apply(update: update))
                }
                return left
            case .delete: return right
            }
        case .update:
            switch right.operation {
            case .add: return left      /* unexpected */
            case .update: 
                guard let leftUpdate = left.data as? any UpdateAssertable, let rightUpdate = right.data as? any UpdateAssertable else { return left }
                return Assertion(leftUpdate.apply(update: rightUpdate))
            case .delete: return right
            }
        case .delete:
            switch right.operation {
            case .add: return right
            case .update: return left   /* unexpected */
            case .delete: return left   /* unexpected */
            }
        }
    }
    
    internal static func addApplyUpdate<Add: AddAssertable>(left: Add, right: Add.Update) -> any AddAssertable {
        return left.apply(update: right)
    }
    
    private static func updateApplyUpdate<Update: UpdateAssertable>(left: Update, right: Update) -> any UpdateAssertable {
        return left.apply(update: right)
    }
    
    enum CodingKeys: String, CodingKey {
        case code
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(data.code, forKey: .code)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let code = try container.decode(AssertionCode.self, forKey: .code)
        self.init(code: code)
    }
}

public protocol Assertable: Identifiable, Codable, Equatable {
    var id: UUID { get }
    var operation: AssertionOperation { get }
    var model: AssertionModel { get }
    var code: AssertionCode { get }
    
    func willModify(_ basis: DataBasis) -> Bool
}

public enum AssertionCode: Codable, Equatable {
    case addSong(Song)
    case addAlbum(Album)
    case addArtist(Artist)
    case updateSong(SongUpdate)
    case updateAlbum(AlbumUpdate)
    case updateArtist(ArtistUpdate)
    case delete(DeleteAssertion)
}

public enum AssertionOperation {
    case add
    case update
    case delete
}

public enum AssertionModel: String, Codable {
    case song
    case album
    case artist
}
 

// MARK: - Add
public protocol AddAssertable: Assertable {
    associatedtype Update: UpdateAssertable
    func apply(update: Update) -> Self
}

extension AddAssertable {
    public var operation: AssertionOperation { return .add }
    
    func apply(update: any UpdateAssertable) -> Self {
        guard let selfUpdate = update as? Self.Update else { return self }
        return self.apply(update: selfUpdate)
    }
}


// MARK: - Update
public protocol UpdateAssertable: Assertable {
    func apply(update: Self) -> Self
}

extension UpdateAssertable {
    public var operation: AssertionOperation { return .update }
    
    func apply(update: any UpdateAssertable) -> Self {
        guard let selfUpdate = update as? Self else { return self }
        return self.apply(update: selfUpdate)
    }
}

// MARK: - Delete
public protocol DeleteAssertable: Assertable { }

extension DeleteAssertable {
    public var operation: AssertionOperation { return .delete }
}


