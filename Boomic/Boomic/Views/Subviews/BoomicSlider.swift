//
//  BoomicSlider.swift
//  Boomic
//
//  Created by Kevin Kelly on 11/7/22.
//

import SwiftUI

struct BoomicSlider<S: Shape>: View
{
    @Binding var percent : Double
    let vertical : Bool
    let shape : S
    /// Constant update: update the value during the gesture and not just on end
    let constantUpdates : Bool
    
    init(percent: Binding<Double>, shape: S, vertical: Bool = false, constantUpdates: Bool = false)
    {
        self._percent = percent
        self.vertical = vertical
        self.shape = shape
        self.constantUpdates = constantUpdates
    }
    
    var body: some View
    {
        GeometryReader
        {
            geo in __Slider(
                percent: $percent,
                geometry: geo,
                vertical: vertical,
                shape: shape,
                constantUpdates: constantUpdates
            )
        }
    }
    
    // TODO: Make the constantUpdates make more sense and generally clean this up
    private struct __Slider<S: Shape> : View
    {
        @Binding var percent : Double
        @State var offset : Double = 0.0
        let geometry : GeometryProxy
        let vertical : Bool
        let shape : S
        let constantUpdates : Bool
        
        func onChanged(_ value: DragGesture.Value)
        {
            let _offset : CGFloat
            // set the offset to the new value
            if vertical {_offset = (-value.translation.height / geometry.size.height)}
            else { _offset = (value.translation.width / geometry.size.width)}
            // correct for out of bounds gestures
            if ((percent + _offset) > 1) {offset = 1-percent}
            else if ((percent + _offset) < 0) {offset = -percent}
            else {offset = _offset}
        }
        
        func onEnded(_ value: DragGesture.Value)
        {
            offset = 0.0
            // set the percentage to the new value
            if vertical {percent += (-value.translation.height / geometry.size.height)}
            else {percent += (value.translation.width / geometry.size.width)}
            // correct for out of bounds gestures
            if (percent > 1) {percent = 1}
            else if (percent < 0) {percent = 0}
        }
        
        // TODO: Implent constantChanges
        
        var body: some View
        {
            let drag = DragGesture()
                .onChanged {
                    value in onChanged(value)
                }
                .onEnded {
                    value in onEnded(value)
                }

            ZStack(alignment: .bottomLeading)
            {
                Rectangle()
                    .foregroundColor(.gray)
                
                if vertical
                {
                    Rectangle()
                        .frame(height: (geometry.size.height) * (percent + offset))
                }
                else
                {
                    Rectangle()
                        .frame(width: (geometry.size.width) * (percent + (constantUpdates ? 0 : offset)))
                }
                
            }
            .clipShape(shape)
            .gesture(drag)
            //.frame(height: C.frame)
        }
        
        typealias C = ViewConstants.Subviews.BoomicSlider
    }
}

struct BoomicSlider_Previews: PreviewProvider
{
    static var previews: some View
    {
        BoomicSlider(percent: .constant(0.5), shape: (Capsule()))
    }
}
