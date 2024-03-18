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
    }
    
    
    static let gridPadding : CGFloat = 8
    static let albumCornerRadius : CGFloat = 8
    
    static let albumSpacers : CGFloat = 70
    
    static let buttonCornerRadius : CGFloat = 12
    static let buttonHeight : CGFloat = 55
}
