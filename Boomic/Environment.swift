//
//  Environment.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/16/24.
//

import SwiftUI
import Repository
import MediaPlayerKit

struct RepositoryEnvironmentKey: EnvironmentKey {
    static let defaultValue: Repository = Repository()
}

struct PlayerEnvironmentKey: EnvironmentKey {
    static let defaultValue: SongPlayer = SongPlayer()
}

extension EnvironmentValues {
    var repository: Repository {
        get { self[RepositoryEnvironmentKey.self] }
        set { self[RepositoryEnvironmentKey.self] = newValue }
    }
    
    var player: SongPlayer {
        get { self[PlayerEnvironmentKey.self] }
        set { self[PlayerEnvironmentKey.self] = newValue }
    }
}

