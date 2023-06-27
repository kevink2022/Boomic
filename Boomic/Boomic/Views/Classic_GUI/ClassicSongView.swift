//
//  ClassicSongView.swift
//  Boomic
//
//  Created by Kevin Kelly on 11/1/22.
//

import SwiftUI

struct ClassicSongView: View
{
    @EnvironmentObject var manager : BoomicManager
    let song : Song
    @Namespace var currentSong
    
    var body: some View
    {
        ZStack
        {
            ImageBlurBackground(image: song.albumCover)
            
            VStack(alignment: .leading)
            {
                if manager.showQueueSheet
                {
                    QueueList()
                    
                    Button
                    {
                        withAnimation(.easeIn(duration: 0.2)) { manager.showQueueSheet.toggle() }
                    }
                    label:
                    {
                        SongEntry(song: song, namespace: currentSong)
                    }
                    .padding(.horizontal)
                }
                else
                {
                    CurrentSongAlbumCover(song: song)
                        .matchedGeometryEffect(id: "album_cover", in: currentSong)
                    
                    SongTitles(song: song)
                        .matchedGeometryEffect(id: "titles", in: currentSong)
                }
                
                if manager.songExists
                {
                    ClassicTimeSlider()
                }
                else
                {
                    HStack
                    {
                        Spacer()
                        Image(systemName: "externaldrive.trianglebadge.exclamationmark")
                        Text("The song file cannot be found")
                        Spacer()
                    }
                }
                
                ClassicMediaControls()
                    .padding(.vertical)
                
                ClassicVolumeSlider()
                    .padding()
                
                ClassicQueueControls()
                    .padding(.top)
            }
        }
    }
}

struct ClassicSongView_Previews: PreviewProvider {
    static var previews: some View {
        ClassicSongView(song: Song.standard)
            .environmentObject(BoomicManager())
        ClassicSongView(song: Song.standard).preferredColorScheme(.dark)
            .environmentObject(BoomicManager())
    }
}

