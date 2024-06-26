//
//  Navigator.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/1/24.
//

import SwiftUI
import UniformTypeIdentifiers

private typealias A = ViewConstants.Animations

@Observable
public final class Navigator {
    
    public var tab = TabNavigation.home {
        willSet {
            if tab == newValue {
                switch tab {
                case .home: library.toRoot()
                case .settings: settings.toRoot()
                case .search:
                    search.toRoot()
                    isSearchFocused = true
                default: break
                }
            }
        }
    }
    public func toTab(_ tab: TabNavigation) {
        if self.tab != tab {
            // prevent triggering double tabs on programatic navigation
            self.tab = tab
        }
    }
    
    public var library = NavigationPath() {
        didSet {
            isSearchFocused = false
        }
    }
    
    public var settings = NavigationPath()
    public var search = NavigationPath() {
        didSet {
            isSearchFocused = false
        }
    }
    
    public var showSheet: Bool = false
    public var sheetContent: AnyView? = nil
    
    func presentSheet<V: View>(_ view: V) {
        self.sheetContent = AnyView(view)
        self.showSheet = true
    }
    
    func dismissSheet() {
        self.showSheet = false
    }
    
    
    public var showFiles: Bool = false {
        didSet {
            if showFiles == false {
                fileTypes = []
                allowMultiSelection = false
                filePickerCompletion = { _ in }
            }
        }
    }
    public var fileTypes: [UTType] = []
    public var allowMultiSelection: Bool = false
    public var filePickerCompletion: (Result<[URL], any Error>) -> Void = { _ in }
    
    public func showFilePicker(
        for types: [UTType]
        , allowMultiSelection: Bool = false
        , onCompletion: @escaping (Result<[URL], any Error>) -> Void
    ) {
        self.fileTypes = types
        self.allowMultiSelection = allowMultiSelection
        self.filePickerCompletion = onCompletion
        self.showFiles = true
    }
    
    public var isSearchFocused: Bool = false
    
    public var playerOffset: CGFloat = 800
    public var playerFullscreen = false
    public var hidePlayerBar: Bool { isSearchFocused }
    
    public func closePlayer() {
        withAnimation(A.playerExit) {
            playerOffset = 1000
        } completion: {
            self.playerFullscreen = false
        }
    }
    
    public func openPlayer() {
        // putting the full logic here breaks the animation
        playerFullscreen = true
    }
}

extension NavigationPath {
    mutating func toRoot() {
        self.removeLast(self.count)
    }
    
    mutating func navigateTo(_ value: any Hashable, clearingPath: Bool = false) {
        if clearingPath {
            self.toRoot()
        }
        self.append(value)
    }
    
    mutating func navigateBack() {
        self.removeLast()
    }
}

public enum LibraryNavigation: String, CaseIterable, Identifiable, Hashable, Codable {
   
    case songs, albums, artists, topRated, taglists
    
    public var id : String { self.rawValue }
}

// Not on the home screen
public enum MiscLibraryNavigation: String, CaseIterable, Identifiable, Hashable, Codable {
    
    case newTaglist
    
    public var id : String { self.rawValue }
}

public enum SettingsNavigation: String, CaseIterable, Identifiable, Hashable, Codable {
    
    case tagViews , libraryData, transactionList, accentColorPicker, tabOrder, libararyPanelOrder, newTagView
    
    public var id : String { self.rawValue }
}


public enum TabNavigation: String, CaseIterable, Identifiable, Hashable, Codable {
   
    case home, settings, mixer, search
    
    public var id : String { self.rawValue }
}



