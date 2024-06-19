//
//  TaglistScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/16/24.
//

import SwiftUI

import Models

private typealias C = ViewConstants
private typealias F = ViewConstants.Fonts
private typealias A = ViewConstants.Animations
private typealias SI = ViewConstants.SystemImages


struct TaglistScreen: View {
    @Environment(\.repository) private var repository
    @State private var builder: TaglistBuilder
    
    private let baseTaglist: Taglist?
    private var taglist: Taglist { baseTaglist ?? .empty }
    
    init(taglist: Taglist? = nil) {
        self.baseTaglist = taglist
        self.builder = TaglistBuilder(taglist ?? .empty)
    }
    
    private var songs: [Song] {
        let time = Date.now
        let songs = repository.songs().filter { song in
            Taglist.evaulate(song.tags, onPositiveRules: builder.positiveRules, onNegativeRules: builder.negativeRules)
        }
        let interval = time.timeIntervalSinceNow
        print("Tag Filter: \(String(describing: interval))")
        return songs
    }

    var body: some View {
        ScrollView {
            LazyVStack {
                Text(builder.title)
                    .font(F.screenTitle)
            
                ForEach($builder.positiveRules, id: \.self) { $rule in
                    TagRuleField(rule: $rule, positive: true, editing: builder.editing)
                }
                
                if builder.editing && nil == builder.positiveRules.first(where: { $0 == .empty }) {
                    AnimatedButton {
                        builder.positiveRules.append(.empty)
                    } label: {
                        TagRuleField(rule: .constant(.empty), positive: true, editing: false)
                            .opacity(0.3)
                    }
                    .foregroundColor(.primary)
                }
                
                ForEach($builder.negativeRules, id: \.self) { $rule in
                    TagRuleField(rule: $rule, positive: false, editing: builder.editing)
                }
                
                if builder.editing && nil == builder.negativeRules.first(where: { $0 == .empty }) {
                    AnimatedButton {
                        builder.negativeRules.append(.empty)
                    } label: {
                        TagRuleField(rule: .constant(.empty), positive: false, editing: false)
                            .opacity(0.3)
                    }
                    .foregroundColor(.primary)
                }
            
                if builder.editing {
                    HStack {
                        LargeButton(role: .destructive) {
                            builder = TaglistBuilder(taglist)
                            //builder.editing = false
                        } label: {
                            HStack {
                                Image(systemName: SI.cancelSelection)
                                Text("Cancel")
                            }
                        }
                        
                        LargeButton {
                            //TaglistSaveMenu(taglist: taglist, editing: $builder.editing)
                            builder.editing = false
                        } label: {
                            HStack {
                                Image(systemName: SI.save)
                                Text("Save")
                            }
                        }
                    }
                    .frame(height: C.buttonHeight)
                    .padding(.vertical)
                } else {
                    LargePlayShuffleButtons(songs: songs, queueName: taglist.title)
                        .padding(.vertical)
                }
            }
            .padding(C.gridPadding)
            
            SongGrid(
                songs: songs
                , key: nil
                , config: .smallIconList
                , header: .standard
                , selectable: true
                , title: "Songs"
                , queueName: builder.title
                , showTrackNumber: false
            )
        }
        
        .toolbar {
            //temp
            Menu {
                Button {
                    Task {
                        await repository.setActiveSublibrary(from: builder.asNewTaglist())
                    }
                } label: {
                    Label("Set as Sublibrary", systemImage: SI.tag)
                }
                
                Button {
                    repository.setGlobalLibrary()
                } label: {
                    Label("Reset to global library", systemImage: SI.home)
                }
            } label: {
                Image(systemName: SI.temporary)
                    .font(F.toolbarButton)
            }
            
            Menu {
                TaglistMenu(taglist: taglist, editing: $builder.editing)
            } label: {
                Image(systemName: SI.information)
                    .font(F.toolbarButton)
            }
        }
    }
}

#Preview {
    NavigationStack {
        TaglistScreen()
            .environment(\.repository, PreviewMocks.shared.livePreviewRepository())
    }
}

@Observable
fileprivate final class TaglistBuilder {
    var title: String
    var useBuilder: Bool = false
    var editing: Bool = false {
        didSet {
            if editing == false {
                positiveRules = positiveRules.filter { !$0.isEmpty }
                negativeRules = negativeRules.filter { !$0.isEmpty }
            }
        }
    }
    
    init(_ taglist: Taglist) {
        self.title = taglist.title
        self.positiveRules = taglist.positiveRules
        self.negativeRules = taglist.negativeRules
    }
    
    public var positiveRules: [TagRule]
    public var negativeRules: [TagRule]
    
    public func overwriteList() {
        
    }
    
    public func saveNewList(title: String) {
        
    }
    
    public func saveTemporarily(title: String) {
        
    }
    
    public func asNewTaglist() -> Taglist {
        return Taglist(
            title: title
            , positiveRules: positiveRules
            , negativeRules: negativeRules
        )
    }
    
//    public func asTaglistUpdate() -> Taglist {
//        return Taglist(
//            title: <#T##String#>
//            , id: <#T##UUID#>
//            , positiveRules: <#T##[TagRule]#>
//            , negativeRules: <#T##[TagRule]#>
//        )
//    }
}


struct TagRuleField: View {
    let positive: Bool
    let editing: Bool
    @Binding private var rule: TagRule
    @State private var text: String = ""
    @State private var tags: Set<Tag>
    
    init(
        rule: Binding<TagRule>
        , positive: Bool = true
        , editing: Bool = false
    ) {
        self._rule = rule
        self.positive = positive
        self.editing = editing
        self.text = ""
        self.tags = rule.wrappedValue.tags
    }
    
    var body: some View {
        HStack {
            Image(systemName: positive ? SI.add : SI.remove)
                .font(F.playerButton)
            
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .stroke(style: StrokeStyle(lineWidth: 3))
                
                TagEntryField(tags: $tags, editing: editing)
                    .padding(10)
                    .onChange(of: tags) {
                        rule = TagRule(tags: tags)
                    }
            }
        }
        .padding(.horizontal, C.gridPadding)
        .padding(.vertical, 2)
    }
}

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
                    ForEach(Array(tags), id: \.self) { tag in
                        AnimatedButton {
                            tags.remove(tag)
                            text = tag.description
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
                                .onSubmit {
                                    if let tag = Tag.from(text) {
                                        withAnimation(A.standard) {
                                            tags.insert(tag)
                                            text = ""
                                            focused = true
                                        }
                                    }
                                }
                        }
                    }
                }
            }
        }
    }
}

    
