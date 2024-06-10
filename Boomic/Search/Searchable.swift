//
//  Searchable.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/8/24.
//

import Foundation
import Models

enum SearchLevel: CaseIterable, Comparable {
    case secondary, primary
}

protocol Searchable {
    func search(_ predicate: String) -> SearchLevel?
}

extension Array where Element: Searchable {
    func search(_ predicate: String) -> ([Element], [Element]) {
        let primary = self.searchPrimary(predicate)
        let secondary = self.searchSecondary(predicate)
        return (primary, secondary)
    }
    
    func search(_ predicate: String) -> [Element] {
        guard predicate != "" else { return self }
        let (primary, secondary) = self.search(predicate)
        return primary + secondary
    }
    
    func searchPrimary(_ predicate: String) -> [Element] {
        guard predicate != "" else { return self }
        let primary = self.filter { $0.search(predicate) == .primary }
        return primary
    }
    
    private func searchSecondary(_ predicate: String) -> [Element] {
        guard predicate != "" else { return [] }
        let secondary = self.filter { $0.search(predicate) == .secondary }
        return secondary
    }
    
    func search(_ predicate: String, primaryOnly: Bool = false) -> [Element] {
        if primaryOnly {
            return searchPrimary(predicate)
        } else {
            return search(predicate)
        }
    }
}

extension Song: Searchable {
    func search(_ predicate: String) -> SearchLevel? {
        if self.label.contains(predicate) { return .primary }
        
        else if
            self.artistName?.contains(predicate) ?? false
            || self.albumTitle?.contains(predicate) ?? false
        {
            return .secondary
        }
        
        else { return nil }
    }
}

extension Album: Searchable {
    func search(_ predicate: String) -> SearchLevel? {
        if self.title.contains(predicate) { return .primary }
        if self.artistName?.contains(predicate) ?? false { return .secondary }
        else { return nil }
    }
}

extension Artist: Searchable {
    func search(_ predicate: String) -> SearchLevel? {
        if self.name.contains(predicate) { return .primary }
        else { return nil }
    }
}
