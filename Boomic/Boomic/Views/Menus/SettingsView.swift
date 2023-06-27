//
//  SettingsView.swift
//  Boomic
//
//  Created by Kevin Kelly on 12/10/22.
//

import SwiftUI

struct SettingsView: View
{
    @EnvironmentObject var manager : BoomicManager
    
    var body: some View
    {
        VStack
        {
            List
            {
                Section("Current Song GUI")
                {
                    Picker("Song GUI", selection: $manager.library.settings.songGUI)
                    {
                        ForEach(S.SongGUI.allCases)
                        {
                            setting in Text(setting.rawValue).tag(setting)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Time Slider")
                {
                    Picker("Time Slider", selection: $manager.library.settings.classicTimeSlider)
                    {
                        ForEach(S.ClassicTimeSlider.allCases)
                        {
                            setting in Text(setting.rawValue).tag(setting)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Album Cover Gestures")
                {
                    Picker("Album Cover", selection: $manager.library.settings.albumCover)
                    {
                        ForEach(S.AlbumCover.allCases)
                        {
                            setting in Text(setting.rawValue).tag(setting)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            
            if let song = manager.currentSong {
                Button {manager.showCurrentSongSheet = true }
                    label: { CurrentSongBar(song: song) }
            }
        }
    }
    
    typealias S = BoomicSettings
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
