//
//  AnimatedButton.swift
//  Boomic
//
//  Created by Kevin Kelly on 4/23/24.
//

import SwiftUI

struct AnimatedButton<Label: View> : View{
    let animation: Animation
    let action: () -> Void
    let label: () -> Label
    
    init(
        _ animation: Animation = .default
        , action: @escaping () -> Void
        , @ViewBuilder label: @escaping () -> Label
    ) {
        self.animation = animation
        self.action = action
        self.label = label
    }
    
    var body: some View {
        Button {
            withAnimation(animation) {
                action()
            }
        } label: {
            label()
        }
    }
}

#Preview {
    AnimatedButton() {
        
    } label: {
        Text("hello")
    }
}
