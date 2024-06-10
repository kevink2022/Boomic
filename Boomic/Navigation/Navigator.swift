//
//  Navigator.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/1/24.
//

import SwiftUI

private typealias A = ViewConstants.Animations

@Observable
public final class Navigator {
    
    public var library = NavigationPath() {
        didSet {
            isSearchFocused = false
        }
    }
    
    public var tab = TabNavigation.home {
        willSet {
            if tab == newValue {
                switch tab {
                case .home: library.toRoot()
                default: break
                }
            }
        }
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
    
    mutating func navigateTo(_ value: any Hashable) {
        self.append(value)
    }
}

public enum LibraryNavigation : String, CaseIterable, Identifiable, Hashable, Codable {
   
    case songs, albums, artists, topRated, taglists
    
    public var id : String { self.rawValue }
}

public enum TabNavigation : String, CaseIterable, Identifiable, Hashable, Codable {
   
    case home, settings, mixer, search
    
    public var id : String { self.rawValue }
}



