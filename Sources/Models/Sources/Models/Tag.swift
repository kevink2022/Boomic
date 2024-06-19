//
//  File.swift
//  
//
//  Created by Kevin Kelly on 6/15/24.
//

import Foundation

public struct Tag: Equatable, Codable, Hashable, CustomStringConvertible {
    let body: String
    
    private init(_ body: String) {
        self.body = body
    }
    
    public static func from(_ string: String) -> Tag? {
        let trimmed = string.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }
                
        var sanitized = trimmed
        guard let firstCharacter = sanitized.first else { return nil }
        
        if !tagCharset.contains(firstCharacter) {
            sanitized.insert(Self.tag, at: sanitized.startIndex)
        }

        for char in sanitized.dropFirst() {
            if excludedCharacters.contains(char) {
                return nil
            }
        }
        
        return Tag(sanitized)
    }
    
//    private static let allowedCharacters = CharacterSet
//        .alphanumerics
//        .union(CharacterSet(charactersIn: "_-")
//    )
    
    private static let excludedCharacters = CharacterSet(charactersIn: "!@#$%^&*()+=[]{}|\\;:'\",.<>/?`~")
    
    private static let tag: Character = "#"
    private static let tagCharset: Set<Character> = [
        Self.tag
    ]
    
    
    public var description: String {
        return body
    }
}

extension CharacterSet {
    fileprivate func contains(_ character: Character) -> Bool {
        return character.unicodeScalars.allSatisfy { self.contains($0) }
    }
}

public struct TagRule: Codable, Equatable, Hashable {
    public let tags: Set<Tag>
    
    public init(tags: Set<Tag>) {
        self.tags = tags
    }
    
    /*
     * At the moment, a set passes if it contains any one
     * of the tags in the rule.
     */
    public func evaluate(tags evaluating: Set<Tag>) -> Bool {
        for tag in self.tags {
            if evaluating.contains(tag) { return true }
        }
        
        return false
    }
    
    public var isEmpty: Bool { tags.isEmpty }
    public var list: [Tag] { Array(tags).sorted(by: { $0.description < $1.description })}
    
    public static let empty = TagRule(tags: [])
}

public final class Taglist: Identifiable, Codable, Hashable {
    public static func == (lhs: Taglist, rhs: Taglist) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public let title: String
    public let id: UUID
    
    public let positiveRules: [TagRule]
    public let negativeRules: [TagRule]
    
    public init(
        title: String
        , id: UUID = UUID()
        , positiveRules: [TagRule]
        , negativeRules: [TagRule]
    ) {
        self.title = title
        self.id = id
        self.positiveRules = positiveRules
        self.negativeRules = negativeRules
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
    
    public static let empty = Taglist(title: "New Taglist", positiveRules: [], negativeRules: [])
}
