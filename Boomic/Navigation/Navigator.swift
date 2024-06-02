//
//  Navigator.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/1/24.
//

import SwiftUI

@Observable
public final class Navigator {
    
    public var library = NavigationPath()
}

public enum LibraryNavigation : String, CaseIterable, Identifiable
{
    case songs, albums, artists
    
    public var id : String { self.rawValue }
}

