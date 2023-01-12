//
//  ImageBlurBackground.swift
//  Boomic
//
//  Created by Kevin Kelly on 11/8/22.
//

import SwiftUI

struct ImageBlurBackground: View
{
    let image : ImageSource?
    
    var body: some View
    {
        Image(image ?? .asset(C.defaultAlbumCover))
            .resizable()
            .scaleEffect(3)
            .ignoresSafeArea()
            .blur(radius: 50)
            .opacity(0.2)
    }
    
    typealias C = ViewConstants.Subviews.ImageBlurBackground
}

//struct ImageBlurBackground_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageBlurBackground(image: "ratatat-magnifique")
//        ImageBlurBackground(image: "ratatat-magnifique").preferredColorScheme(.dark)
//        ImageBlurBackground(image: "ratatat-classics")
//        ImageBlurBackground(image: "ratatat-classics").preferredColorScheme(.dark)
//    }
//}
