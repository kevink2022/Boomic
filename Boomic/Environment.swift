//
//  Environment.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/16/24.
//

import SwiftUI
import Repository

struct RepositoryEnvironmentKey: EnvironmentKey {
    static let defaultValue: Repository = RepositoryImpl()
}

extension EnvironmentValues {
    var repository: Repository {
        get { self[RepositoryEnvironmentKey.self] }
        set { self[RepositoryEnvironmentKey.self] = newValue }
    }
}

