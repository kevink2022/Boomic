//
//  DynamicGrid.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/19/24.
//

import SwiftUI

private typealias C = ViewConstants
private typealias F = ViewConstants.Fonts
private typealias A = ViewConstants.Animations
private typealias SI = ViewConstants.SystemImages

struct DynamicGrid<Content: View>: View {
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
                    AnimatedButton(A.dynamicGridRevealButtons) {
                        showTitleButtons.toggle()
                    } label: {
                        Image(systemName: SI.dynamicGridRevealControls)
                            .rotationEffect(showTitleButtons ? .degrees(180) : .zero)
                    }
                    
                    if showTitleButtons {
                        Button {
                            withAnimation {
                                zoomOut()
                            }
                        } label: {
                            Image(systemName: SI.dynamicGridZoomOut)
                        }
                        .disabled(!canZoomOut)
                        
                        Button {
                            withAnimation {
                                zoomIn()
                            }
                        } label: {
                            Image(systemName: SI.dynamicGridZoomIn)
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
}

#Preview {
    DynamicGrid(title: "Albums") {
        ForEach(PreviewMocks.shared.previewArtists()) { artist in
            //ArtistGridLink(artist: artist)
        }
    }
}
