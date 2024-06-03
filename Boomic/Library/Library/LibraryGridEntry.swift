//
//  LibraryGridEntry.swift
//  Boomic
//
//  Created by Kevin Kelly on 4/1/24.
//

import SwiftUI

private typealias C = ViewConstants
private typealias F = ViewConstants.Fonts

struct LibraryGridEntry: View {
    let title: String
    let imageName: String
    
    var body: some View {
        VStack(alignment: .center) {
            ZStack {
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(C.libraryGridObjectInternalPadding)
                    
                RoundedRectangle(cornerSize: CGSize(
                    width: C.albumCornerRadius,
                    height: C.albumCornerRadius
                ))
                .stroke(style: StrokeStyle(lineWidth: C.libraryGridObjectStroke))
                .aspectRatio(contentMode: .fit)
            }
            
            Text(title)
                .font(F.listTitle)
                .lineLimit(1)
        }
        
        .padding(.horizontal, C.libraryGridPadding)
    }
}

#Preview {
    LibraryScreen()
        .environment(\.repository, PreviewMocks.shared.previewRepository())
}



