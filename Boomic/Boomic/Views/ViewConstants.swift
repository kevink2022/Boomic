//
//  ViewConstants.swift
//  Boomic
//
//  Created by Kevin Kelly on 11/1/22.
//

import SwiftUI

/// View Constants Organization
///     - C: Each File gets its own constants struct, aliased with C
///     - F: Each subgroup get a fonts struct, which may borrow from the root fonts, aliased with F
///     - P: Placeholders for development, and when metadata is unavailable, aliased with P

struct ViewConstants
{
    /// For general placeholder text/images
    struct Placeholders
    {
        struct Unknown
        {
            static let artist = "Unknown Artist"
            static let album = "Unknown Album"
        }
    }
    
    struct Menus
    {
        struct Fonts
        {
            static let title = Font.system(.title3, design: .default, weight: .semibold)
            static let artist = Font.system(.subheadline, design: .default, weight: .regular)
        }
        
        struct SongListItem
        {
            static let height : CGFloat = 40
        }
        
        struct Subviews
        {
            
        }
        
        struct AlbumListItem
        {
            static let titleFont = Font.system(.title, design: .default, weight: .bold)
            static let artistFont = Font.system(.subheadline, design: .default, weight: .regular)
            static let cornerRadius : CGFloat = 15
        }
    }
    
    struct Subviews
    {
        struct ImageBlurBackground
        {
            static let defaultAlbumCover : String = ViewConstants.Subviews.AlbumCover.defaultAlbumCover
        }
        
        struct AlbumCover
        {
            static let padding : CGFloat = 2
            static let cornerRadius : CGFloat = 8
            static let defaultAlbumCover : String = "boomic_logo"
        }
        
        struct BoomicSlider
        {
            static let frame : CGFloat = 10
        }
    }
    
    struct Classic_GUI
    {
        struct Fonts
        {
            static let title = Font.system(.largeTitle, design: .default, weight: .bold)
            static let artist = Font.system(.title3, design: .default, weight: .light)
            static let album = Font.system(.title3, design: .default, weight: .light)
            static let time = Font.system(.body, design: .default, weight: .light)
            static let mediaControls = Font.system(.largeTitle, design: .default, weight: .heavy)
            static let queueControls = Font.system(.title3, design: .default, weight: .bold)
        }
        
        
        
        struct Subviews
        {
            struct ClassicMediaControls
            {
                static let playSF = "play.fill"
                static let pauseSF = "pause.fill"
                static let lastSongSF = "backward.fill"
                static let nextSongSF = "forward.fill"
                static let color = Color.primary
            }
            
            struct ClassicTitles
            {
                static let lineLimit = 1
            }

            struct ClassicVolumeSlider
            {
                static let lowVolumeSF = "speaker.wave.1.fill"
                static let highVolumeSF = "speaker.wave.3.fill"
            }
            
            struct ClassicQueueControls
            {
                static let shuffleSF = "shuffle"
                static let inOrderSF = "arrow.forward"
                
                static let dontRepeatSF = "arrow.forward.to.line"
                static let repeatQueueSF = "repeat"
                static let repearSongSF = "repeat.1"
                static let singleSongSF = "1.circle"
                
                static let queueSF = "list.triangle"
            }
        }
    }
}
