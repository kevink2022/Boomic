//
//  ScrollingTimeView.swift
//  Boomic
//
//  Created by Kevin Kelly on 12/8/22.
//

import SwiftUI

struct ScrollingTimeView: View
{
    @Binding var percent : Double
    let samples : [Float]
    let frame : CGFloat
    let vertical : Bool
    
    init(percent: Binding<Double>, samples: [Float], frame: CGFloat, vertical: Bool = false) {
        self._percent = percent
        self.samples = samples
        self.frame = frame
        self.vertical = vertical
    }
    
    var body: some View
    {
        if vertical { Vertical(samples: samples, percent: $percent, frame: frame) }
        
        else { Horizontal(samples: samples, percent: $percent, frame: frame) }
    }
    
    private struct Horizontal: View
    {
        let samples : [Float]
        @State var offset = 0.0
        @Binding var percent : Double
        let frame : CGFloat
        var translation : Double { 1 - percent }
        
        var body: some View
        {
            let size : Double = (Double(samples.count) * (C.capsuleWidth + C.capsuleSpacing))
            let heightMultiplier : Double = (frame - C.capsuleWidth) / Double(samples.max() ?? 0.1)
            
            let drag = DragGesture()
                .onChanged
                {
                    value in
                    
                    let _offset = Double(value.translation.width) / size
                    
                    if ((translation + _offset) > 1) {offset = 1-translation}
                    else if ((translation + _offset) < 0) {offset = -translation}
                    else {offset = _offset}
                    
                }
                .onEnded
                {
                    value in
                    offset = 0.0

                    let _translation = translation + value.translation.width/Double(size)
                    
                    if _translation > 1 {percent = 0}
                    else if _translation < 0 {percent = 1}
                    else { percent = (1-_translation) }
                }

            HStack(spacing: 0)
            {
                Rectangle().foregroundColor(.primary)
                Rectangle().foregroundColor(.gray)
            }
            .mask
            {
                HStack(spacing: CGFloat(C.capsuleSpacing))
                {
                    ForEach(samples.indices, id: \.self)
                    {
                        sample in
                        
                        Capsule()
                            .frame(
                                width: CGFloat(C.capsuleWidth),
                                height: CGFloat(C.capsuleWidth + max(heightMultiplier*Double(samples[sample]), 0) )
                            )
                        
                    }
                    .offset(x: CGFloat( ((translation + offset)*size) - (size/2) ) )
                }
            }
            .gesture(drag)
            .frame(height: frame)
        }
    }
    
    private struct Vertical: View
    {
        let samples : [Float]
        @State var offset = 0.0
        @Binding var percent : Double
        let frame : CGFloat
        var translation : Double { 1 - percent }
        
        var body: some View
        {
            let size : Double = (Double(samples.count) * (C.capsuleWidth + C.capsuleSpacing))
            let heightMultiplier : Double = (frame - C.capsuleWidth) / Double(samples.max() ?? 0.1)
            
            let drag = DragGesture()
                .onChanged
                {
                    value in
                    
                    // MARK: Change
                    let _offset = Double(value.translation.height) / size
                    
                    if ((translation + _offset) > 1) {offset = 1-translation}
                    else if ((translation + _offset) < 0) {offset = -translation}
                    else {offset = _offset}
                    
                }
                .onEnded
                {
                    value in
                    offset = 0.0

                    // MARK: Change
                    let _translation = translation + value.translation.height/Double(size)
                    
                    if _translation > 1 {percent = 0}
                    else if _translation < 0 {percent = 1}
                    else { percent = (1-_translation) }
                }

            // MARK: Change
            VStack(spacing: 0)
            {
                Rectangle().foregroundColor(.primary)
                Rectangle().foregroundColor(.gray)
            }
            .mask
            {
                // MARK: Change
                VStack(spacing: CGFloat(C.capsuleSpacing))
                {
                    ForEach(samples.indices, id: \.self)
                    {
                        sample in
                        
                        // MARK: Change
                        Capsule()
                            .frame(
                                width: CGFloat(C.capsuleWidth + max(heightMultiplier*Double(samples[sample]), 0)),
                                height: CGFloat(C.capsuleWidth)
                            )
                        
                    }
                    // MARK: Change
                    .offset(y: CGFloat( ((translation + offset)*size) - (size/2) ) )
                }
            }
            .gesture(drag)
            .frame(width: frame)
        }
    }
    
    typealias C = ViewConstants.Subviews.ScrollingTimeView
}

//struct ScrollingTimeView_Previews: PreviewProvider
//{
//    static var previews: some View
//    {
//        ScrollingTimeView()
//    }
//}


extension ViewConstants.Subviews
{
    struct ScrollingTimeView
    {
        static let capsuleWidth = Double(10)
        static let capsuleSpacing = Double(2)
        static let heightMultiplier = Double(100000)
        
        static let samples : [Float] = [0.1, 0, 0.2, 0, 0.2, 0.4, 0.2, 0.3, 0, 0.1, 0, 0.2, 0, 0.2, 0.4, 0.2, 0.3, 0, 0.1, 0, 0.2, 0, 0.2, 0.4, 0.2, 0.3, 0, 0.1, 0, 0.2, 0, 0.2, 0.4, 0.2, 0.3, 0, 0.1, 0, 0.2, 0, 0.2, 0.4, 0.2, 0.3, 0, 0.1, 0, 0.2, 0, 0.2, 0.4, 0.2, 0.3, 0, 0.1, 0, 0.2, 0, 0.2, 0.4, 0.2, 0.3, 0, 0.1, 0, 0.2, 0, 0.2, 0.4, 0.2, 0.3, 0, 0.1, 0, 0.2, 0, 0.2, 0.4, 0.2, 0.3, 0, 0.1, 0, 0.2, 0, 0.2, 0.4, 0.2, 0.3, 0, 0.1, 0, 0.2, 0, 0.2, 0.4, 0.2, 0.3, 0, 0.1, 0, 0.2, 0, 0.2, 0.4]
    }
}


