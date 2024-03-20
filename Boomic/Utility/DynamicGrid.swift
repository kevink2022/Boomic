//
//  DynamicGrid.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/19/24.
//

import SwiftUI

struct DynamicGrid<Content: View> : View{
    let content: () -> Content
    let title: String
    let titleFont: Font
    
    init(title: String
         , titleFont: Font = F.sectionTitle
         , @ViewBuilder content: @escaping () -> Content)
    {
        self.title = title
        self.titleFont = titleFont
        self.content = content
    }
    
    let column: GridItem = GridItem.init(.flexible())
    @State var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    @State var showTitleButtons = false
    
    let chevron = "chevron.left.circle"
    let minColumns = 2
    let maxColumns = 5
    
    var canZoomIn: Bool { columns.count > minColumns }
    
    func zoomIn() {
        if canZoomIn {
            columns.removeFirst()
        }
    }
    
    var canZoomOut: Bool { columns.count < maxColumns }
    
    func zoomOut() {
        if canZoomOut {
            columns.append(column)
        }
        
    }
    
    var body: some View {
        ScrollView {
            HStack {
                Text(title)
                    .font(titleFont)
 
                Spacer()
                
                HStack {
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) { showTitleButtons.toggle() }
                    } label: {
                        Image(systemName: chevron)
                            .rotationEffect(showTitleButtons ? .degrees(180) : .zero)
                    }
                    
                    if showTitleButtons {
                        Button {
                            withAnimation {
                                zoomOut()
                            }
                        } label: {
                            Image(systemName: "minus.circle")
                        }
                        .disabled(!canZoomOut)
                        
                        Button {
                            withAnimation {
                                zoomIn()
                            }
                        } label: {
                            Image(systemName: "plus.circle")
                        }
                        .disabled(!canZoomIn)
                    }
                }
                .font(F.listTitle)

            }

            LazyVGrid(columns: columns, alignment: .leading) {
                content()
            }
            
        }        
    }
    
    typealias C = ViewConstants
    typealias F = ViewConstants.Fonts
}

#Preview {
    DynamicGrid(title: "Albums") {
        ForEach(previewArtists()) { artist in
            ArtistGridLink(artist: artist)
        }
    }
}
