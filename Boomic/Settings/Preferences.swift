//
//  Preferences.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/4/24.
//

import SwiftUI

import Foundation

import Domain
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
    
    var localSearchOnlyPrimary: Bool { didSet { Task { try await localSearchOnlyPrimaryStore.save(localSearchOnlyPrimary) } } }
    private let localSearchOnlyPrimaryStore: SimpleStore<Bool>
    
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
        
        self.localSearchOnlyPrimary = false
        self.localSearchOnlyPrimaryStore = SimpleStore<Bool>(key: Keys.libraryOrder, cached: false, namespace: Keys.namespace, inMemory: inMemory)
                
        Task {
            let savedGrids = await (try? gridStore.load())
            self.grids = savedGrids ?? KeySet()
            
            let savedTabOrder = await (try? tabOrderStore.load())
            self.tabOrder = savedTabOrder ?? TabNavigation.allCases
            
            if let savedLibraryOrder = await (try? libraryOrderStore.load()) {
                let newButtons = LibraryNavigation.allCases.filter { !savedLibraryOrder.contains($0) }
                self.libraryOrder = savedLibraryOrder + newButtons
            }
            
            let savedLocalSearchOnlyPrimary = await (try? localSearchOnlyPrimaryStore.load())
            self.localSearchOnlyPrimary = savedLocalSearchOnlyPrimary ?? false
        }
    }
}

extension Preferences {
    func loadGrid(key: String, default fallback: GridListConfiguration = .threeColumns) -> GridListConfiguration {
        grids[key] ?? GridListConfiguration(key: key, columnCount: fallback.columnCount, showLabels: fallback.showLabels)
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
        static let localSearchOnlyPrimary = "localSearchOnlyPrimary"
    }
    
    final class GridKeys {
        static let allSongs = "allSongs"
        static let allAlbums = "allAlbums"
        static let allArtists = "allArtists"
        static let artistAlbums = "artistAlbums"
        static let albumArtists = "albumArtists"
        static let library = "library"
    }
}
