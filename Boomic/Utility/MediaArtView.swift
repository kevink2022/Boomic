//
//  MediaArtView.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/30/24.
//

import SwiftUI
import Models

struct MediaArtView: View {
    let art: MediaArt?
    
    init(_ art: MediaArt? = nil) {
        self.art = art
    }
    
    var body: some View {
        {
            switch art {
            case .local(let url): 
                return Image("boomic_logo")
            default: return Image("boomic_logo")
            }
        }()
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

#Preview {
    MediaArtView()
}
