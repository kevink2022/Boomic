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
    
    public var library = NavigationPath()
    
    public var tab = TabNavigation.home
    
    public var playerOffset: CGFloat = 800
    public var playerFullscreen = false
    
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

public enum LibraryNavigation : String, CaseIterable, Identifiable, Hashable {
   
    case songs, albums, artists
    
    public var id : String { self.rawValue }
}

public enum TabNavigation : String, CaseIterable, Identifiable, Hashable {
   
    case home, settings, mixer, search
    
    public var id : String { self.rawValue }
}



