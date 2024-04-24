//
//  ViewConstants.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/16/24.
//

import SwiftUI

struct ViewConstants {
    struct Fonts {
        static let listTitle = Font.system(
            .title3
            , design: .default
            , weight: .semibold
        )
        static let listSubtitle = Font.system(
            .subheadline
            , design: .default,
            weight: .regular
        )
        
        static let title = Font.system(
            .title
            , design: .default
            , weight: .bold
        )
        static let subtitle = Font.system(
            .title3
            , design: .default
            , weight: .regular
        )
        
        static let sectionTitle = Font.system(
            .title
            , design: .default
            , weight: .bold
        )
        static let screenTitle = Font.system(
            .largeTitle
            , design: .default
            , weight: .bold
        )
        
        static let trackNumber = Font.system(
            .subheadline
            , design: .monospaced
            , weight: .thin
        )
        static let listDuration = Font.system(
            .subheadline
            , design: .default
            , weight: .light
        )
        static let body = Font.system(
            .body
            , design: .default
            , weight: .medium
        )
        static let bold = Font.system(
            .body
            , design: .default
            , weight: .bold
        )
        
        static let playerButton = Font.system(
            .title
            , design: .default
            , weight: .bold
        )
        static let playbackButton = Font.system(
            .largeTitle
            , design: .default
            , weight: .bold
        )
    }
    
    struct Animations {
        static let standard: Animation = .default
        static let showPlayer: Animation = .spring(duration: 0.2)
        static let albumSnap: Animation = .snappy(duration: 0.2)
        static let playerExit: Animation = .easeOut
        static let timeSliderExpansion: Animation = .easeOut(duration: 0.05)
        static let toggleQueue: Animation = .snappy(duration: 0.3)
        static let artistScreenShowAllSongs: Animation = .easeOut(duration: 0.2)
        static let dynamicGridRevealButtons: Animation = .easeInOut(duration: 0.15)
    }
    
    struct SystemImages {
        static let songs = "music.quarternote.3"
        static let album = "opticaldisc"
        static let artist = "music.mic"
        static let addSongs = add
        
        static let add = "plus.circle"
        static let remove = "minus.circle"
        
        static let pause = "pause.fill"
        static let play = "play.fill"
        static let backwardSkip = "backward.fill"
        static let forwardSkip = "forward.fill"
        
        static let edit = "pencit.circle"
        static let tag = "number"
        static let rate = "star"
        static let rateCircle = "star.circle"
        static let infoCircle = "info.circle"
        static let addToPlaylist = "text.append"
        
        static let noRepeat = "arrow.forward.to.line"
        static let repeatQueue = "repeat"
        static let repeatSong = "repeat.1"
        static let oneSong = "1.circle"
        
        static let inOrder = "arrow.right"
        static let shuffle = "shuffle"
        
        static let queue = "list.bullet"
        static let topOfQueue = "text.line.first.and.arrowtriangle.forward"
        static let bottomOfQueue = "text.line.last.and.arrowtriangle.forward"
        
        static let queueListDuration = "clock"
        static let queueListDelete = remove
        static let queueListSwap = "arrow.up.arrow.down.circle"
        static let queueListMoveUp = "arrow.up.circle"
        static let queueListMoveDown = "arrow.down.circle"
        
        static let dynamicGridRevealControls = "chevron.left.circle"
        static let dynamicGridZoomIn = add
        static let dynamicGridZoomOut = remove
    }
    
    static let gridPadding: CGFloat = 8
    static let albumCornerRadius: CGFloat = 8
    
    static let songListEntryPadding: CGFloat = 7
    static let songTrackNumberWidth: CGFloat = 22
    
    static let albumScreenSpacers: CGFloat = 70
    static let artistScreenHeaderPadding: CGFloat = 110
    
    static let artistHorizontalListEntryWidth: CGFloat = 120
    static let artistHorizontalListEntryHeight: CGFloat = 150
    
    static let buttonCornerRadius: CGFloat = 12
    static let buttonHeight: CGFloat = 55
    
    static let smallAlbumFrame: CGFloat = 50
    static let smallAlbumCornerRadius: CGFloat = 4
    
    static let backgroundBlurRadius: CGFloat = 50
    static let backgroundBlurScaleEffect: CGFloat = 3
    static let backgroundBlurOpacity: CGFloat = 0.2
    
    static let playerTitlePaddingTop: CGFloat = playerTitlePaddingBottom * 2
    static let playerTitlePaddingBottom: CGFloat = 10
    
    static let playbackButtonScaleEffect: CGFloat = 1.3
    
    static let timeSliderHeight: CGFloat = 10
    static let timeSliderExpandedHeight: CGFloat = 15
    static let timeSliderOpacity: CGFloat = 0.15
    
    static let queueControlsBarCornerRadius: CGFloat = 15
    static let queueControlsBarOpacity: CGFloat = 0.1
    static let queueControlsBarHeight: CGFloat = 50
    
    static let queueNameOpacity: CGFloat = 0.5
    
    static let libraryGridObjectInternalPadding: CGFloat = 20
    static let libraryGridObjectStroke: CGFloat = 5
    static let libraryGridPadding: CGFloat = 3

}

#Preview {
    ContentView()
        .environment(\.repository, livePreviewRepository())
        .environment(\.player, previewPlayer())
}
