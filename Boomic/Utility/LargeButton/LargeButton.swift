//
//  LargeButton.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/17/24.
//

import SwiftUI

private typealias C = ViewConstants
private typealias F = ViewConstants.Fonts

struct LargeButton<Label>: View where Label: View {
    let role: ButtonRole?
    let action: () -> Void
    let label: () -> Label
    
    init(
        role: ButtonRole? = nil
        , action: @escaping () -> Void
        , @ViewBuilder label: @escaping () -> Label
    ) {
        self.role = role
        self.action = action
        self.label = label
    }
    
    var body: some View {
        Button(role: role, action: action) {
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
    LargeButton {
        
    } label: {
        HStack {
            Image(systemName: "play.fill")
            Text("Play")
        }
    }
}
