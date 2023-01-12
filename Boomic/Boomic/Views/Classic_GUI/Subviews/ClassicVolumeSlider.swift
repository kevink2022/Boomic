//
//  ClassicVolumeSlider.swift
//  Boomic
//
//  Created by Kevin Kelly on 11/2/22.
//

import SwiftUI

struct ClassicVolumeSlider: View
{
    @EnvironmentObject var manager : BoomicManager
    
    var body: some View
    {
        HStack
        {
            Image(systemName: C.lowVolumeSF)
            
            BoomicSlider(percent: $manager.volume, shape: Capsule(), constantUpdates: true)
            
            Image(systemName: C.highVolumeSF)
        }
        .frame(height: 10)
    }
    
    typealias C = ViewConstants.Classic_GUI.Subviews.ClassicVolumeSlider
}


struct ClassicVolumeSlider_Previews: PreviewProvider {
    static var previews: some View {
        ClassicVolumeSlider()
    }
}


//import MediaPlayer
//import UIKit

//struct ClassicVolumeSlider: UIViewRepresentable
//{
//    func makeUIView(context: Context) -> MPVolumeView
//    {
//        MPVolumeView(frame: .zero)
//    }
//
//    func updateUIView(_ view: MPVolumeView, context: Context) { }
//}


