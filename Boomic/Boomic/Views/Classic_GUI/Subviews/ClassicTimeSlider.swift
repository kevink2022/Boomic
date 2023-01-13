//
//  ClassicTimeSlider.swift
//  Boomic
//
//  Created by Kevin Kelly on 11/4/22.
//

import SwiftUI

struct ClassicTimeSlider: View
{
    @EnvironmentObject var manager : BoomicManager
    
    var body: some View
    {
        switch manager.library.settings.classicTimeSlider
        {
        case .classic: Classic()
        case .scrolling: Scrolling()
        }
    }
    
    private struct Scrolling : View
    {
        @EnvironmentObject var manager : BoomicManager
        
        var body: some View
        {
            ScrollingTimeView(percent: $manager.songProgress, samples: manager.audioLevelSamples, frame: 60)
        }
    }
    
    private struct Classic : View
    {
        @EnvironmentObject var manager : BoomicManager
        
        var body: some View
        {
            VStack(spacing: 0)
            {
                // TODO: I don't like this direct access to the player in the GUI, but it will work with the buffer
                HStack
                {
                    Text("\(manager.player.currentTime().seconds.readable)")

                    Spacer()

                    Text("\(manager.player.currentItem!.duration.seconds.readable)")
                }
                .font(F.time)
                
                BoomicSlider(percent: $manager.songProgress, shape: Capsule())

                .frame(height: 20)
            }
            .padding()
        }
    }
    
    typealias F = ViewConstants.Classic_GUI.Fonts
}

struct ClassicTimeSlider_Previews: PreviewProvider {
    static var previews: some View {
        ClassicTimeSlider()
            .environmentObject(BoomicManager())
    }
}


extension Double
{
    var readable : String
    {
        if self > 0
        {
            let h : Int = Int(self/3600)
            let m : Int = Int(self)%3600/60
            let s : Int = Int(self)%60
            
            if h > 0
            {
                return String(format: "%i:%02i:%02i", h, m, s)
            }
            else
            {
                return String(format: "%i:%02i", m, s)
            }
        }
        else { return "0:00" }
    }
}

