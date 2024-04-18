//
//  OptionalMatchedGeometryEffect.swift
//  Boomic
//
//  Created by Kevin Kelly on 4/15/24.
//

import SwiftUI

struct OptionalMatchedGeometryEffect: ViewModifier {
    var id: String
    var namespace: Namespace.ID?

    func body(content: Content) -> some View {
        if let ns = namespace {
            content.matchedGeometryEffect(id: id, in: ns)
        } else {
            content
        }
    }
}

extension View {
    func matchedGeometryEffect(id: String, in namespace: Namespace.ID?) -> some View {
        modifier(OptionalMatchedGeometryEffect(id: id, namespace: namespace))
    }
}
