//
//  LibraryGridEntry.swift
//  Boomic
//
//  Created by Kevin Kelly on 4/1/24.
//

import SwiftUI

struct LibraryGridEntry: View {
    let title: String
    let imageName: String
    
    var body: some View {
        VStack(alignment: .center) {
            ZStack {
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(20)
                
                RoundedRectangle(cornerSize: CGSize(
                    width: C.albumCornerRadius,
                    height: C.albumCornerRadius
                ))
                .stroke(style: StrokeStyle(lineWidth: 5))
                .aspectRatio(contentMode: .fit)
            }
            
            Text(title)
                .font(F.listTitle)
                .lineLimit(1)
        }
        
        .padding(.horizontal, 3)
    }
    
    private typealias C = ViewConstants
    private typealias F = ViewConstants.Fonts
}

#Preview {
    LibraryScreen()
        .environment(\.repository, previewRepository())
}



