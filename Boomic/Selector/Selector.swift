//
//  Selector.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/12/24.
//

import Foundation

enum SelectionGroup {
    case songs, artists, albums
}

@Observable
final class ModelSelector {
    var selected: Set<UUID> = []
    var group: SelectionGroup? = nil
    
    var active: Bool { group != nil }
    var noSelections: Bool { selected.count == 0 }
    
    func toggleSelect(_ id: UUID, group: SelectionGroup?) {
        if active && self.group == group {
            if selected.contains(id) {
                selected.remove(id)
            } else {
                selected.insert(id)
            }
        }
    }
    
    func selectGroup(_ group: SelectionGroup) {
        self.group = group
    }
    
    func select(_ id: UUID) {
        selected.insert(id)
    }
    
    func select(_ ids: [UUID]) {
        selected.formUnion(ids)
    }
    
    func deselect(_ id: UUID) {
        selected.remove(id)
    }
    
    func cancel() {
        group = nil
        selected = []
    }
    
    func isSelected(_ id: UUID?) -> Bool {
        if let id = id {
            return selected.contains(id)
        }
        return false
    }
}
