//
//  Environment.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/16/24.
//

import SwiftUI
import Database

struct DatabaseEnvironmentKey: EnvironmentKey {
    static let defaultValue: Database = try! CacheDatabase() // Provide a default
}

extension EnvironmentValues {
    var database: Database {
        get { self[DatabaseEnvironmentKey.self] }
        set { self[DatabaseEnvironmentKey.self] = newValue }
    }
}
