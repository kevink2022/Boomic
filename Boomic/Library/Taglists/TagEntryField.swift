//
//  TagEntryField.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/20/24.
//

import SwiftUI
import Models

private typealias A = ViewConstants.Animations

struct TagEntryField: View {
    @State private var text: String = ""
    @Binding private var tags: Set<Tag>
    @FocusState private var focused: Bool
    let editing: Bool
    
    init(
        tags: Binding<Set<Tag>>
        , editing: Bool = false
    ) {
        self._tags = tags
        self.text = ""
        self.editing = editing
    }
    
    var body: some View {
        ZStack {
            Button {
                focused = true
            } label: {
                Color(UIColor.systemBackground)
            }
            .disabled(!editing)
            
            VStack(alignment: .leading) {
                WrappingHStack(horizontalSpacing: 5) {
                    ForEach(tags.byLength, id: \.self) { tag in
                        AnimatedButton {
                            if editing {
                                tags.remove(tag)
                                text = tag.description
                            }
                        } label: {
                            TagPill(tag)
                        }
                    }
                }
                
                if editing {
                    Button {
                        focused = true
                    } label: {
                        VStack(alignment: .leading) {
                            TextField(text: $text, prompt: Text("Add Tag")) { EmptyView() }
                                .focused($focused)
                                .multilineTextAlignment(.leading)
                                .onSubmit {
                                    //focused = true
                                    onSubmit()
                                }
                        }
                    }
                }
            }
        }
    }
    
    private func onSubmit() {
            if let tag = Tag.from(text) {
                withAnimation(A.standard) {
                    tags.insert(tag)
                    text = ""
                }
            }
    }
}


#Preview {
    TagEntryField(tags: .constant([]))
}
