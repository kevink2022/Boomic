//
//  ShuffleButton.swift
//  Boomic
//
//  Created by Kevin Kelly on 12/11/22.
//

import SwiftUI

struct ShuffleButton: View
{
    @EnvironmentObject var manager : BoomicManager
    
    var body: some View
    {
        Button
        {
            manager.toggleShuffle()
        }
        label:
        {
            Image(shuffleLabel())
                .resizable()
                .foregroundColor(.primary)
        }
    }
    
    func shuffleLabel() -> ImageSource
    {
        switch manager.shuffleState
        {
        case .inOrder : return .systemName(C.inOrderSF)
        case .shuffle : return .systemName(C.shuffleSF)
        }
    }
    
    typealias C = ViewConstants.Classic_GUI.Subviews.ClassicQueueControls
    
}

struct ShuffleButton_Previews: PreviewProvider {
    static var previews: some View {
        ShuffleButton()
    }
}
