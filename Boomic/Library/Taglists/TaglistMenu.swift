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
    private var listType: String { builder.subLibraryMode ? "SubLibrary" : "Taglist" }
    
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
    private var listType: String { builder.subLibraryMode ? "SubLibrary" : "Taglist" }
    
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
            Task {
                let new = builder.asNewTaglist()
                await repository.addTaglists([new])
                //navigator.library.navigateTo(new)
            }
        } label: {
            Label("New \(listType)", systemImage: SI.new)
        }
        
        AnimatedButton {
            builder.editing = false
            // use builder for songs
        } label: {
            Label("Temporary \(listType)", systemImage: SI.temporary)
        }
        
        if !builder.new {
            AnimatedButton {
                builder.editing = false
                Task {
                    let update = builder.asTaglistUpdate()
                    await repository.updateTaglists([update])
                    //navigator.library.navigateTo(new)
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
