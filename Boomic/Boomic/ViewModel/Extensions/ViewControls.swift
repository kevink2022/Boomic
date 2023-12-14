//
//  ViewControls.swift
//  Boomic
//
//  Created by Kevin Kelly on 8/21/23.
//

import Foundation

@MainActor
extension BoomicManager
{
    func currentSongSheetStatus(_ show: Bool)
    {
        self.showCurrentSongSheet = show
    }
    
    func queueSheetStatus(_ show: Bool)
    {
        self.showQueueSheet = show
    }
}
