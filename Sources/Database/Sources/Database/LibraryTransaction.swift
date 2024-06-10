//
//  File.swift
//  
//
//  Created by Kevin Kelly on 6/6/24.
//

import Foundation
import Domain

public final class LibraryTransaction: Codable {
    public let label: String
    public let level: LibraryTransactionLevel
    public let assertions: KeySet<Assertion>
    
    init(
        label: String
        , level: LibraryTransactionLevel
        , assertions: KeySet<Assertion>
    ) {
        self.label = label
        self.level = level
        self.assertions = assertions
    }
    
    public static func flatten(_ transactions: [LibraryTransaction]) -> LibraryTransaction  {
        LibraryTransaction(
            label: "Flattened"
            , level: transactions.reduce(.normal, { partialResult, transaction in max(partialResult, transaction.level) })
            , assertions: Assertion.flatten(transactions.map{ $0.assertions })
        )
    }
    
    public static let empty = LibraryTransaction(label: "Empty", level: .normal, assertions: KeySet())
}

public enum LibraryTransactionLevel: String, Codable, Comparable {
    public static func < (lhs: LibraryTransactionLevel, rhs: LibraryTransactionLevel) -> Bool {
        switch (lhs, rhs) {
        case (.normal, .significant):
            return true
        case (.significant, .normal):
            return false
        default:
            return false
        }
    }
    
    case significant, normal
}


extension KeySet where Element == Assertion {
    public func asTransaction(label: String = "assertions", level: LibraryTransactionLevel = .normal) -> LibraryTransaction {
        return LibraryTransaction(
            label: label
            , level: level
            , assertions: self
        )
    }
}
