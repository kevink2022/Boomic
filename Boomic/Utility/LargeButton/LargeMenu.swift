//
//  LargeMenu.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/20/24.
//

import SwiftUI

private typealias C = ViewConstants
private typealias F = ViewConstants.Fonts

struct LargeMenu<Content, Label>: View where Content: View, Label: View {
    let content: () -> Content
    let label: () -> Label
    
    init(@ViewBuilder content: @escaping () -> Content, @ViewBuilder label: @escaping () -> Label) {
        self.content = content
        self.label = label
    }
    
    var body: some View {
        Menu {
            content()
        } label: {
            ZStack {
                RoundedRectangle(cornerSize: CGSize(
                        width: C.buttonCornerRadius,
                        height: C.buttonCornerRadius)
                    )
                    .fill(.secondary)
                    .opacity(0.4)
                
                label()
                    .font(F.listTitle)
            }
        }

        
    }
}
#Preview {
    LargeMenu {
        Text("Text")
    } label: {
        Image(systemName: "circle")
    }
}
