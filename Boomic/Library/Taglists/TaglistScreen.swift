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
    
    private let isForSublibrary: Bool
    private let baseTaglist: Taglist
    private var taglist: Taglist { repository.taglist(baseTaglist) ?? baseTaglist }
    
    init(
        taglist: Taglist?
        , forSubLibrary isForSublibrary: Bool = false
    ) {
        self.baseTaglist = taglist ?? .empty
        self.isForSublibrary = isForSublibrary
        self.builder = TaglistBuilder(
            taglist ?? .empty
            , new: taglist == nil
            , forSubLibrary: isForSublibrary
        )
    }
    
    private var songs: [Song] {
        repository.songs().filter { song in
            Taglist.evaulate(song.tags, onPositiveRules: builder.positiveRules, onNegativeRules: builder.negativeRules)
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack {
                HStack {
                    TextField(text: $builder.title, prompt: Text("Add Tag")) { EmptyView() }
                        .multilineTextAlignment(.center)
                        .font(F.screenTitle)
                        .disabled(!builder.editing)
                }
                
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
                            withAnimation { builder = TaglistBuilder(taglist, forSubLibrary: isForSublibrary) }
                        } label: {
                            HStack {
                                Image(systemName: SI.cancelSelection)
                                Text("Cancel")
                            }
                        }
                        
                        LargeMenu {
                            TaglistSaveMenu(taglist: taglist, builder: $builder)
                        } label: {
                            HStack {
                                Image(systemName: SI.save)
                                Text("Save as")
                            }
                        }
                        .disabled(builder.disableSave)
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
                TaglistMenu(taglist: taglist, builder: $builder)
            } label: {
                Image(systemName: SI.information)
                    .font(F.toolbarButton)
            }
        }
    }
}

#Preview {
    NavigationStack {
        TaglistScreen(taglist: nil)
            .environment(\.repository, PreviewMocks.shared.livePreviewRepository())
    }
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
                        print(tags)
                        rule = TagRule(tags: tags)
                        print(rule)
                    }
            }
        }
        .padding(.horizontal, C.gridPadding)
        .padding(.vertical, 2)
    }
}


    
