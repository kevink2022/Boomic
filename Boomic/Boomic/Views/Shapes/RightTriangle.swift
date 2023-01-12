//
//  RightTriangle.swift
//  Boomic
//
//  Created by Kevin Kelly on 12/7/22.
//

import SwiftUI

struct RightTriangle: Shape
{
    func path(in rect: CGRect) -> Path
    {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        return path
    }
}

struct RightTriangleView: View
{
    var body: some View
    {
        ZStack
        {
        RightTriangle()
            .fill(.black)
//            RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
//            .mask(RightTriangle())
            
        }
        .padding()
    }
}

struct RightTriangle_Previews: PreviewProvider {
    static var previews: some View {
        RightTriangleView()
    }
}
