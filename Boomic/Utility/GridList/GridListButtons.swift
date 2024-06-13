//
//  GridListButtons.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/5/24.
//

import SwiftUI

private typealias C = ViewConstants
private typealias F = ViewConstants.Fonts
private typealias A = ViewConstants.Animations
private typealias SI = ViewConstants.SystemImages

struct GridListButtons: View {
    @Binding var config: GridListConfiguration
    let font: Font
    @State private var showTitleButtons: Bool
    
    init(
        config: Binding<GridListConfiguration>
        , font: Font = F.playerButton
    ) {
        self._config = config
        self.font = font
        self.showTitleButtons = false
    }
    
    var body: some View {
        HStack {
            AnimatedButton(A.dynamicGridRevealButtons) {
                showTitleButtons.toggle()
            } label: {
                Image(systemName: SI.dynamicGridRevealControls)
                    .rotationEffect(showTitleButtons ? .degrees(180) : .zero)
                    .font(font)
            }
            
            if showTitleButtons {
                AnimatedButton(A.standard) {
                    config.showLabels.toggle()
                } label: {
                    if config.showLabels && config.gridMode {
                        ZStack {
                            Image(systemName: SI.dynamicGridNegative)
                            Image(systemName: SI.dynamicGridShowLabel)
                                .opacity(0.5)
                        }
                        .font(font)
                    } else {
                        Image(systemName: SI.dynamicGridShowLabel)
                            .font(font)
                    }
                }
                .disabled(config.listMode)
                
                AnimatedButton(A.standard) {
                    config.zoomOut()
                } label: {
                    Image(systemName: SI.dynamicGridZoomOut)
                        .font(font)
                }
                .disabled(!config.canZoomOut)
                
                AnimatedButton(A.standard) {
                    config.zoomIn()
                } label: {
                    Image(systemName: SI.dynamicGridZoomIn)
                        .font(font)
                }
                .disabled(!config.canZoomIn)
            }
        }
    }
}

#Preview {
    GridListButtons(config: .constant(.threeColumns))
}
