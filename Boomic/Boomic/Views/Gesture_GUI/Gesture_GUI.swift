//
//  Gesture_GUI.swift
//  Boomic
//
//  Created by Kevin Kelly on 12/7/22.
//

import SwiftUI

struct Gesture_GUI: View
{
    @EnvironmentObject var manager : BoomicManager
    let song : Song
    
    var body: some View
    {
        ZStack
        {
            ImageBlurBackground(image: song.albumCover)
            
            GeometryReader
            {
                geo in
                
                VStack
                {
                    GesturedAlbumCover()
                        .frame(height: geo.size.width - 2)
                    
                    ZStack
                    {
                        GeometryReader
                        {
                            geo in
                            
                            HStack
                            {
                                ScrollingTimeView(
                                    percent: $manager.songProgress,
                                    samples: manager.audioLevelSamples,
                                    frame: geo.size.width/3,
                                    vertical: true
                                )
                                .ignoresSafeArea(.all, edges: .vertical)
                                
                                Spacer()
                                    .frame(width: geo.size.width/3)
                                
                                GestureVolumeSlider()
                                    .frame(width: geo.size.width/3, height: geo.size.height)
                                    .padding(.top)
                            }
                        }
                        .padding(.horizontal)
                        
                        VStack
                        {
                            Spacer()
                            
                            RepeatButton()
                                .frame(width: 35, height: 35)
                            
                            Spacer()
                            
                            PlayButton()
                                .frame(width: 75, height: 75)
                            
                            Spacer()
                            
                            ShuffleButton()
                                .frame(width: 35, height: 35)
                            
                            Spacer()
                        }
                    }
                    SongTitles(song: song, alignment: .center)
                }
            }
        }
    }
}

struct Gesture_GUI_Previews: PreviewProvider {
    static var previews: some View {
        Gesture_GUI(song: Song.standard)
    }
}
