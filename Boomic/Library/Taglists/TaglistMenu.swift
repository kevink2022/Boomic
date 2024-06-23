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
    @Environment(\.repository) private var repository
    
    @Binding private var builder: TaglistBuilder
    private var taglist: Taglist
    private var listType: String { builder.forTagView ? "TagView" : "Taglist" }
    
    init(
        taglist: Taglist
        , builder: Binding<TaglistBuilder>
    ) {
        self.taglist = taglist
        self._builder = builder
    }
    
    var body: some View {
        if !builder.editing {
            AnimatedButton {
                builder.editing = true
            } label: {
                Label("Edit \(listType)", systemImage: SI.edit)
            }
            
            Button(role: .destructive) {
                Task { await repository.deleteTaglists([taglist]) }
            } label: {
                Label("Delete \(listType)", systemImage: SI.delete)
            }
            
        } else {
            Menu {
                TaglistSaveMenu(taglist: taglist, builder: $builder)
                    .disabled(builder.disableSave)
            } label: {
                Label("Save as", systemImage: SI.save)
            }
        }
    }
}

struct TaglistSaveMenu: View {
    @Environment(\.navigator) private var navigator
    @Environment(\.repository) private var repository
    
    @Binding private var builder: TaglistBuilder
    private let baseTaglist: Taglist
    private var taglist: Taglist { baseTaglist }
    private var listType: String { builder.forTagView ? "TagView" : "Taglist" }
    
    init(
        taglist: Taglist
        , builder: Binding<TaglistBuilder>
    ) {
        self.baseTaglist = taglist
        self._builder = builder
    }
    
    var body: some View {
        Button {
            builder.editing = false
            let new = builder.asNewTaglist()
            if builder.forTagView {
                repository.saveTagView(new)
            } else {
                Task { await repository.addTaglists([new]) }
            }
        } label: {
            Label("New \(listType)", systemImage: SI.new)
        }
        
        if !builder.forTagView {
            AnimatedButton {
                builder.editing = false
                // use builder for songs
            } label: {
                Label("Temporary \(listType)", systemImage: SI.temporary)
            }
        }
        
        if !builder.new {
            AnimatedButton {
                builder.editing = false
                if builder.forTagView {
                    let update = builder.asTaglistUpdate()
                    let new = builder.baseTaglist.apply(update: update)
                    repository.saveTagView(new)
                } else {
                    let update = builder.asTaglistUpdate()
                    Task { await repository.updateTaglists([update]) }
                }
            } label: {
                Label("Overwrite '\(taglist.label)'", systemImage: SI.edit)
            }
        }
    }
}

#Preview {
    TaglistMenu(taglist: .empty, builder: .constant(TaglistBuilder(.empty)))
}
