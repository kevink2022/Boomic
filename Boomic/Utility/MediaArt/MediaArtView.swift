//
//  MediaArtView.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/30/24.
//

import SwiftUI
import Models
import MediaFileKit

struct MediaArtView: View {
    @Environment(\.repository) private var repository
    let art: MediaArt?
    let aspectRatio: ContentMode
    let cornerRadius: CGFloat
    @State var image: Image?
    
    init(
        _ art: MediaArt? = nil
        , aspectRatio: ContentMode = .fit
        , cornerRadius: CGFloat = 0
    ) {
        self.art = art
        self.aspectRatio = aspectRatio
        self.cornerRadius = cornerRadius
        self.image = nil
    }
    
    var body: some View {
        Rectangle()
            .opacity(0)
            .aspectRatio(1, contentMode: aspectRatio)
            .cornerRadius(cornerRadius)
            .overlay {
                showImage()
                    .resizable()
                    .aspectRatio(contentMode: aspectRatio)
                    .cornerRadius(cornerRadius)
            }
            .task {
                if let art = art {
                    image = await repository.artLoader.load(art)
                }
            }
    }
    
    private func showImage() -> Image { image ?? Image("boomic_logo") }
}

#Preview {
    MediaArtView(.test, cornerRadius: 10)
        .environment(\.repository, PreviewMocks.shared.previewRepository())
}
