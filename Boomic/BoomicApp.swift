//
//  BoomicApp.swift
//  Boomic
//
//  Created by Kevin Kelly on 2/7/24.
//

import SwiftUI
import Repository
import MediaPlayerKit
import MediaFileKit

@main
struct BoomicApp: App {
    let repository: Repository
    let player: SongPlayer
    
    init() {
        let repository = Repository()
        let player = SongPlayer(repository: repository)
        
        self.repository = repository
        self.player = player
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.repository, repository)
                .environment(\.player, player)
        }
    }
}
