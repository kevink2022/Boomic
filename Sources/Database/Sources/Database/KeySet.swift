//
//  KeySet.swift
//
//
//  Created by Kevin Kelly on 5/25/24.
//

import Foundation


/// The `KeySet` is just a dictionary that stores values based on their ID.
public struct KeySet<Element: Identifiable> {
    
    public init() {
        storage = [:]
    }
    
    private var storage: [Element.ID: Element] = [:]
    
    public subscript(id: Element.ID) -> Element? {
        return storage[id]
    }
    
    public subscript(element: Element) -> Element? {
        return storage[element.id]
    }
    
    public mutating func insert(_ element: Element) {
        storage[element.id] = element
    }
    
    public func inserting(_ element: Element) -> Self {
        var newSet = self
        newSet.insert(element)
        return newSet
    }
    
    public mutating func insert(_ elements: [Element]) {
        elements.forEach { element in
            self.insert(element)
        }
    }
    
    public func inserting(_ elements: [Element]) -> Self {
        var newSet = self
        elements.forEach { element in
            newSet.insert(element)
        }
        return newSet
    }
    
    public mutating func remove(_ element: Element) {
        storage[element.id] = nil
    }
    
    public func removing(_ element: Element) -> Self {
        var newSet = self
        newSet.remove(element)
        return newSet
    }
    
    public mutating func remove(_ elements: [Element]) {
        elements.forEach { element in
            self.remove(element)
        }
    }
    
    public func removing(_ elements: [Element]) -> Self {
        var newSet = self
        elements.forEach { element in
            newSet.remove(element)
        }
        return newSet
    }
    
    public func contains(_ element: Element) -> Bool {
        return storage[element.id] != nil
    }
    
    public func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) -> Result) -> Result {
        return storage.values.reduce(initialResult, nextPartialResult)
    }
    
    public func reduce<Result>(into initialResult: inout Result, _ updateAccumulatingResult: (inout Result, Element) -> Void) {
        for element in storage.values {
            updateAccumulatingResult(&initialResult, element)
        }
    }
    
    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> KeySet {
        var newSet = KeySet<Element>()
        for element in storage.values {
            if try isIncluded(element) {
                newSet.storage[element.id] = element
            }
        }
        return newSet
    }
    
    public func forEach(_ body: (Element) throws -> Void) rethrows {
        try storage.values.forEach(body)
    }
    
    public var count: Int { storage.count }
    
    public var values: [Element] {
        return Array(storage.values)
    }
}

extension KeySet: Codable where Element: Codable, Element.ID: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(storage, forKey: .storage)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        storage = try container.decode([Element.ID: Element].self, forKey: .storage)
    }

    private enum CodingKeys: String, CodingKey {
        case storage
    }
}

