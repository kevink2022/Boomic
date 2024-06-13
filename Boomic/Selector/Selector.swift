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
    
    func toggleSelect(_ id: UUID, group: SelectionGroup?) {
        if active && self.group == group {
            if selected.contains(id) {
                selected.remove(id)
            } else {
                selected.insert(id)
            }
        }
    }
    
    func select(_ group: SelectionGroup) {
        self.group = group
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
