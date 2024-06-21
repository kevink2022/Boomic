//
//  File.swift
//  
//
//  Created by Kevin Kelly on 6/19/24.
//

import Foundation

public final class Taglist: Model {
    
    public let title: String
    public let id: UUID
    
    public let positiveRules: [TagRule]
    public let negativeRules: [TagRule]
    
    public let songs: [UUID]
    
    public init(
        id: UUID = UUID()
        , title: String
        , positiveRules: [TagRule]
        , negativeRules: [TagRule]
        , songs: [UUID]
    ) {
        self.title = title
        self.id = id
        self.positiveRules = positiveRules
        self.negativeRules = negativeRules
        self.songs = songs
    }
    
    /*
     * For something to be included in a tag list, it must:
     * - Pass each Positive Rules
     * - Not pass each Negative Rule.
     */
    public func evaluate(_ tags: Set<Tag>) -> Bool {
        Self.evaulate(tags, onPositiveRules: positiveRules, onNegativeRules: negativeRules)
    }
    
    public static func evaulate(
        _ tags: Set<Tag>
        , onPositiveRules positiveRules: [TagRule]
        , onNegativeRules negativeRules: [TagRule]
    ) -> Bool {
        
        if positiveRules.isEmpty
            && negativeRules.isEmpty { return false }
        
        if !positiveRules.isEmpty {
            for rule in positiveRules {
                if !rule.evaluate(tags: tags) { return false }
            }
        }
        
        if negativeRules.isEmpty { return true }
        
        for rule in negativeRules {
            if !rule.evaluate(tags: tags) { return true }
        }
        
        return false
    }
    
    public static func == (lhs: Taglist, rhs: Taglist) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static let empty = Taglist(title: "New Taglist", positiveRules: [], negativeRules: [], songs: [])
    
    
    public static let new = Taglist(id: UUID(), title: "New Taglist", positiveRules: [], negativeRules: [], songs: [])
    public static let newSublibrary = Taglist(id: UUID(), title: "New Taglist", positiveRules: [], negativeRules: [], songs: [])
    
    public var label: String { title }
}

extension Taglist {
    public func apply(update: TaglistUpdate) -> Taglist {
        guard self.id == update.taglistID else { return self }
        
        return Taglist(
            id: self.id
            , title: update.newTitle ?? update.title
            , positiveRules: update.positiveRules ?? self.positiveRules
            , negativeRules: update.positiveRules ?? self.positiveRules
            , songs: update.songs ?? self.songs
        )
    }
}

public final class TaglistUpdate: Update {
    public let taglistID: UUID
    public var id: UUID { taglistID }
    public let title: String
    
    public let newTitle: String?
    public let positiveRules: [TagRule]?
    public let negativeRules: [TagRule]?
    public let songs: [UUID]?
    
    private init(
        taglistID: UUID
        , title: String
        , newTitle: String?
        , positiveRules: [TagRule]?
        , negativeRules: [TagRule]?
        , songs: [UUID]?
    ) {
        self.taglistID = taglistID
        self.title = title
        self.newTitle = newTitle
        self.positiveRules = positiveRules
        self.negativeRules = negativeRules
        self.songs = songs
    }
    
    public static func == (lhs: TaglistUpdate, rhs: TaglistUpdate) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public var label: String { title }    
}

extension TaglistUpdate {
    public convenience init(
        taglist: Taglist
        , newTitle: String? = nil
        , positiveRules: [TagRule]? = nil
        , negativeRules: [TagRule]? = nil
        , songs: [UUID]? = nil
    ) {
        self.init(
            taglistID: taglist.id
            , title: taglist.title
            , newTitle: newTitle
            , positiveRules: positiveRules
            , negativeRules: negativeRules
            , songs: songs
        )
    }
    
    public func apply(update: TaglistUpdate) -> TaglistUpdate {
        guard self.id == update.id else { return self }
        
        return TaglistUpdate(
            taglistID: self.taglistID
            , title: self.title
            , newTitle: update.newTitle ?? update.title
            , positiveRules: update.positiveRules ?? self.positiveRules
            , negativeRules: update.positiveRules ?? self.positiveRules
            , songs: update.songs ?? self.songs
        )
    }
    
    public func willModify(_ taglist: Taglist) -> Bool {
        if taglist.title != self.title { return true }
        else if taglist.positiveRules != self.positiveRules { return true }
        else if taglist.negativeRules != self.negativeRules { return true }
        else if taglist.songs != self.songs { return true }
        
        return false
    }
}

