//
//  BoomicSettings.swift
//  Boomic
//
//  Created by Kevin Kelly on 12/10/22.
//

import Foundation

/// I am going with this instead of @AppStorage since this will nicely be
///  saved in the library, and then can be shared that way.
struct BoomicSettings : Codable
{
    var songGUI : SongGUISetting
    var timeSlider : TimeSliderSetting
    var albumGesture : AlbumGestureSetting
    var showArt : ShowAlbumArtSetting
}

// statics
extension BoomicSettings
{
    static let defaultSettings = BoomicSettings(
        songGUI: .classic,
        timeSlider: .classic,
        albumGesture: .notGestured,
        showArt: .show
    )
}

// inits
extension BoomicSettings
{
    
}

// Options ENUMS
extension BoomicSettings
{
    enum SongGUISetting : String, CaseIterable, Codable, Identifiable
    {
        case classic = "Classic GUI"
        case gesture = "Gesture GUI"
        
        var id : String { self.rawValue }
    }
    
    enum TimeSliderSetting : String, CaseIterable, Codable, Identifiable
    {
        case classic = "Classic Slider"
        case scrolling = "Scrolling Slider"
        
        var id : String { self.rawValue }
    }
    
    enum AlbumGestureSetting : String, CaseIterable, Codable, Identifiable
    {
        case notGestured = "Static"
        case gestured = "Gestured"
        
        var id : String { self.rawValue }
    }
    
    enum ShowAlbumArtSetting : String, CaseIterable, Codable, Identifiable
    {
        case show = "Show Album Art"
        case hide = "Hide Album Art"
        
        var id : String { self.rawValue }
    }
}
