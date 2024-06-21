//
//  File.swift
//  
//
//  Created by Kevin Kelly on 6/20/24.
//

import Foundation

public protocol SortedSetable {
    static func compare(_ a: Self, _ b: Self) -> Bool
    static func isEqual(_ a: Self, _ b: Self) -> Bool
}

public struct SortedSet<Element: SortedSetable> {
    
    public init() {
        self.storage = []
    }
    
    private var storage: [Element] = []
    
    public subscript(index: Int) -> Element {
        return storage[index]
    }
    
//    public subscript(element: Element) -> Element? {
//        return storage[element.id]
//    }
    
    public mutating func insert(_ element: Element) {
        if let index = storage.firstIndex(where: { Element.compare($0, element) == false } ) {
            storage.insert(element, at: index)
        } else {
            storage.append(element)
        }
    }
}

extension SortedSet: Codable where Element: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(storage, forKey: .storage)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        storage = try container.decode([Element].self, forKey: .storage)
    }

    private enum CodingKeys: String, CodingKey {
        case storage
    }
}

//struct TestElement: Codable {
//    var string: String
//}
//
//class Test: Codable {
//    var elements = SortedSet<TestElement>(
//        equalOn: { $0.string == $1.string }
//        , compareOn: { $0.string == $1.string }
//    )
//}
