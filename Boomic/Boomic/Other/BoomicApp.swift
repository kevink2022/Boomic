//
//  BoomicApp.swift
//  Boomic
//
//  Created by Kevin Kelly on 11/1/22.
//

import SwiftUI

@main
struct BoomicApp: App
{
    @StateObject var manager = BoomicManager()
    
    var body: some Scene
    {
        WindowGroup
        {
            MainView()
                .environmentObject(manager)
        }
    }
}
