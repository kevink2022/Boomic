//
//  GridListSelectorBar.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/12/24.
//

import SwiftUI

private typealias C = ViewConstants
private typealias F = ViewConstants.Fonts
private typealias A = ViewConstants.Animations
private typealias SI = ViewConstants.SystemImages

struct GridListSelectorBar: View {
    @Environment(\.navigator) private var navigator
    @Environment(\.preferences) private var preferences
    @Environment(\.selector) private var selector
    
    let selectable: Bool
    let externalHorizontalPadding: CGFloat
    
    private var count: Int { selector.selected.count }
    private var show: Bool { selectable && selector.active }
    
    private var model: String {
        switch selector.group {
        case .songs: "Song"
        case .albums: "Album"
        case .artists: "Artist"
        default: ""
        }
    }
    
    var body: some View {
        if !show { EmptyView() }
        
        else {
            ZStack {
                Color(UIColor.systemBackground)
                //Color.primary.opacity(0.1)
                
                VStack(spacing: 0) {
                    Divider()
                    
                    HStack {
                        Button {
                            navigator.presentSheet(ShowAllSelections())
                        } label: {
                            Image(systemName: SI.viewSelections)
                                .font(F.playerButton)
                        }
                        
                        Text(model + (count == 1 ? "" : "s") + " selected: \(count)")
                            .font(F.listEntryTitle)
                            .opacity(0.5)
                        
                        Spacer()
                        
                        Button {
                            
                        } label: {
                            Image(systemName: SI.add)
                                .font(F.playerButton)
                        }
                        
                        Button {
                            
                        } label: {
                            Image(systemName: SI.editSelections)
                                .font(F.playerButton)
                        }
                        
                        AnimatedButton(A.artistScreenShowAllSongs) {
                            selector.cancel()
                        } label: {
                            Image(systemName: SI.cancelSelection)
                                .font(F.playerButton)
                        }
                    }
                    .padding(C.gridPadding)
                    
                    Divider()
                }
            }
            .padding(.horizontal, -externalHorizontalPadding)
        }
    }
}

#Preview {
    GridListSelectorBar(selectable: true, externalHorizontalPadding: 0)
}
