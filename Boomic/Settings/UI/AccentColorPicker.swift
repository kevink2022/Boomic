//
//  AccentColorPicker.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/4/24.
//

import SwiftUI

private typealias C = ViewConstants
private typealias F = ViewConstants.Fonts
private typealias SI = ViewConstants.SystemImages

struct AccentColorPicker: View {
    @Environment(\.preferences) private var preferences
    @State private var sampleColor =
        Color.purple

    var body: some View {
        List {
            ColorPicker("Choose Color", selection: $sampleColor)
            
            Button {
                preferences.accentColor = sampleColor
            } label: {
                Text("Set Accent Color Globally")
            }
            
            Button(role: .destructive) {
                preferences.accentColor = C.defaultAccent
            } label: {
                Text("Reset Accent Color Globally")
            }
            
            Section("Samples") {
                
                Button { } label: {
                    HStack(alignment: .center) {
                        Image(systemName: SI.album)
                        Text("Large")
                    }
                    .font(F.screenTitle)
                }
                .padding(C.gridPadding)
                
                Button { } label: {
                    HStack {
                        Image(systemName: SI.album)
                        Text("Medium")
                    }
                    .font(F.sectionTitle)
                }
                .padding(C.gridPadding)
                
                Button { } label: {
                    HStack {
                        Image(systemName: SI.album)
                        Text("Small")
                    }
                    .font(F.listTitle)
                }
                .padding(C.gridPadding)
                
                Button { } label: {
                    HStack {
                        LargeButton { } label: {
                            HStack {
                                Image(systemName: SI.play)
                                Text("Play")
                            }
                        }
                        
                        LargeButton { } label: {
                            HStack {
                                Image(systemName: SI.shuffle)
                                Text("Shuffle")
                            }
                        }
                    }
                    .frame(height: C.buttonHeight)
                }
                .padding(C.gridPadding)
            }
            .tint(sampleColor)
        }
    }
}

#Preview {
    AccentColorPicker()
}
