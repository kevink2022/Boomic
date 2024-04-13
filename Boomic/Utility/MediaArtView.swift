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
    let art: MediaArt?
    let aspectRatio: ContentMode
    @State var image: Image?
    
    init(_ art: MediaArt? = nil, aspectRatio: ContentMode = .fit) {
        self.art = art
        self.aspectRatio = aspectRatio
        self.image = nil
    }
    
    var body: some View {
        showImage()
            .resizable()
            .aspectRatio(contentMode: aspectRatio)
            .task {
                image = await loadImage()
            }
    }
    
    private func defaultImage() -> Image { Image("boomic_logo") }
    
    private func showImage() -> Image { image ?? defaultImage() }
    
    private func loadImage() async -> Image {
        switch art {
        case .local(let url): urlToImage(url)

        case .embedded(let url): embeddedImage(mediaURL: url)
        default: defaultImage()
        }
    }
    
    private func urlToImage(_ url: URL) -> Image {
#if canImport(UIKit)
        if let uiImage = UIImage(contentsOfFile: url.path) {
            Image(uiImage: uiImage)
        } else { defaultImage() }
#elseif canImport(AppKit)
        if let nsImage = NSImage(contentsOf: url) {
            Image(nsImage: nsImage)
        } else { defaultImage() }
#endif
    }
    
    private func embeddedImage(mediaURL: URL) -> Image {
        guard let data = AudioToolboxParser.embeddedArtData(from: mediaURL)
        else { return defaultImage() }
        
#if canImport(UIKit)
        if let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        } else { return defaultImage() }
#elseif canImport(AppKit)
        if let nsImage = NSImage(data: data) {
            return Image(nsImage: nsImage)
        } else { return defaultImage() }
#endif
    }
}

#Preview {
    MediaArtView(.local(URL(string: "/Users/kevinkelly/Music/Stuff/Ratatat-Magnifique/folder.jpg")!))
}
