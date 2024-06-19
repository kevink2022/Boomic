//
//  TaglistMenu.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/18/24.
//

import SwiftUI
import Models

private typealias SI = ViewConstants.SystemImages

struct TaglistMenu: View {
    @Binding private var editing: Bool
    private var taglist: Taglist
    
    init(
        taglist: Taglist
        , editing: Binding<Bool>
    ) {
        self.taglist = taglist
        self._editing = editing
    }
    
    var body: some View {
        if !editing {
            AnimatedButton {
                editing = true
            } label: {
                Label("Edit Taglist", systemImage: SI.edit)
            }
        } else {
            Menu {
                TaglistSaveMenu(taglist: taglist, editing: $editing)
            } label: {
                Label("Save as", systemImage: SI.save)
            }
        }
    }
}

struct TaglistSaveMenu: View {
    @Binding private var editing: Bool
    private let baseTaglist: Taglist
    private var taglist: Taglist { baseTaglist }
    
    init(
        taglist: Taglist
        , editing: Binding<Bool>
    ) {
        self.baseTaglist = taglist
        self._editing = editing
    }
    
    var body: some View {
        Button {
            editing = false
        } label: {
            Label("New Taglist", systemImage: SI.new)
        }
        
        AnimatedButton {
            editing = false
        } label: {
            Label("Temporary Taglist", systemImage: SI.temporary)
        }
        
        AnimatedButton {
            editing = false
        } label: {
            Label("Overwrite '\(taglist.title)'", systemImage: SI.edit)
        }
    }
}

#Preview {
    TaglistMenu(taglist: .empty, editing: .constant(false))
}
