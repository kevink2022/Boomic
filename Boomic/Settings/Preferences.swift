//
//  Preferences.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/4/24.
//

import SwiftUI

import Foundation
import Database
import Storage

@Observable
final class Preferences {
    
    private var grids: KeySet<GridListConfiguration> { didSet { Task { try await gridStore.save(grids) } } }
    private let gridStore: SimpleStore<KeySet<GridListConfiguration>>
    
    var accentColor: Color
//    private let accentColorStore: SimpleStore<Color>
    
    var tabOrder: [TabNavigation] { didSet { Task { try await tabOrderStore.save(tabOrder) } } }
    private let tabOrderStore: SimpleStore<[TabNavigation]>
    
    var libraryOrder: [LibraryNavigation] { didSet { Task { try await libraryOrderStore.save(libraryOrder) } } }
    private let libraryOrderStore: SimpleStore<[LibraryNavigation]>
    
    init(
        inMemory: Bool = false
    ) {
        self.grids = KeySet()
        self.gridStore = SimpleStore<KeySet<GridListConfiguration>>(key: Keys.grids, cached: false, namespace: Keys.namespace, inMemory: inMemory)
        
        self.accentColor = ViewConstants.defaultAccent
        
        self.tabOrder = TabNavigation.allCases
        self.tabOrderStore = SimpleStore<[TabNavigation]>(key: Keys.tabOrder, cached: false, namespace: Keys.namespace, inMemory: inMemory)
        
        self.libraryOrder = LibraryNavigation.allCases
        self.libraryOrderStore = SimpleStore<[LibraryNavigation]>(key: Keys.libraryOrder, cached: false, namespace: Keys.namespace, inMemory: inMemory)
                
        Task {
            self.grids = await (try? gridStore.load()) ?? KeySet()
            self.tabOrder = await (try? tabOrderStore.load()) ?? TabNavigation.allCases
            self.libraryOrder = await (try? libraryOrderStore.load()) ?? LibraryNavigation.allCases
        }
    }
}

extension Preferences {
    func loadGrid(key: String) -> GridListConfiguration {
        grids[key] ?? GridListConfiguration(key: key)
    }
    
    func saveGrid(_ grid: GridListConfiguration) {
        grids.insert(grid)
    }
}

extension Preferences {
   
    final class Keys {
        static let namespace = "preferences"
        static let accentColor = "accentColor"
        static let grids = "grids"
        static let tabOrder = "tabOrder"
        static let libraryOrder = "libraryOrder"
    }
    
    final class GridKeys {
        static let allAlbums = "allAlbums"
        static let allArtists = "allArtists"
        static let artistAlbums = "artistAlbums"
        static let library = "library"
    }
}
