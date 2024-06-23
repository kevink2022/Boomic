//
//  AlbumArtHeader.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/21/24.
//

import SwiftUI
import Models

private typealias C = ViewConstants

struct AlbumArtHeader: View {
    private let art: MediaArt?
    private let editing: Bool?
    
    init(
        art: MediaArt?
        , editing: Bool? = nil
    ) {
        self.art = art
        self.editing = editing
    }
    
    var body: some View {
        HStack {
            Spacer(minLength: C.albumScreenSpacers)

            MediaArtView(art, cornerRadius: C.albumCornerRadius)
            
            Spacer(minLength: C.albumScreenSpacers)
        }
    }
}

#Preview {
    AlbumArtHeader(art: nil, editing: false)
}
