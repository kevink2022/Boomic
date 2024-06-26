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
    @Environment(\.preferences) var preferences
    
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
                    .fill(preferences.accentColor)
            )
            .foregroundStyle(.white)
    }
}

#Preview {
    TagPill(Tag.from("hello")!)
}
