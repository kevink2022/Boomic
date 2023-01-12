//
//  AlbumCover.swift
//  Boomic
//
//  Created by Kevin Kelly on 11/1/22.
//

import SwiftUI

struct StaticAlbumCover: View
{
    typealias C = ViewConstants.Subviews.AlbumCover
    let image : ImageSource?
    
    var body: some View
    {
        Image(image ?? .asset(C.defaultAlbumCover))
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .cornerRadius(C.cornerRadius)
            .padding(.horizontal, C.padding)
    }
}

struct AlbumCover_Previews: PreviewProvider {
    static var previews: some View {
        StaticAlbumCover(image: .asset("ratatat-magnifique"))
        StaticAlbumCover(image: .asset("ratatat-magnifique")).preferredColorScheme(.dark)
    }
}

extension ViewConstants.Subviews
{
    
}
