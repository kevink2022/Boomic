//
//  TagPill.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/16/24.
//

import SwiftUI
import Models

private typealias F = ViewConstants.Fonts

struct TagPill: View {
    let tag: Tag
    
    init(_ tag: Tag) {
        self.tag = tag
    }
    
    var body: some View {
        Text("\(tag)")
            .font(F.bold)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.accentColor)
            )
            .foregroundStyle(.white)
    }
}

#Preview {
    TagPill(Tag.from("hello")!)
}
