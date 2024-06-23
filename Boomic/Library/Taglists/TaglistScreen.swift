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
    @Environment(\.navigator) private var navigator
    @Environment(\.repository) private var repository
    
    @State private var builder: TaglistBuilder
    
    private let baseTaglist: Taglist
    private var taglist: Taglist { repository.taglist(baseTaglist) ?? baseTaglist }
    
    init(
        taglist: Taglist?
        , forTagView: Bool = false
    ) {
        self.baseTaglist = taglist ?? (forTagView ? .newTagView : .new)
        self.builder = TaglistBuilder(
            taglist ?? (forTagView ? .newTagView : .new)
            , new: taglist == nil
            , forTagView: forTagView
        )
        self.songs = []
    }
    
    @State private var songs: [Song] = []
    private var showArt: Bool { !builder.forTagView }

    var body: some View {
        ScrollView {
            LazyVStack {
                if showArt {
                    HStack {
                        Spacer(minLength: C.albumScreenSpacers)
                        MediaArtEditor($builder.art, editing: builder.editing, cornerRadius: C.albumCornerRadius)
                        Spacer(minLength: C.albumScreenSpacers)
                    }
                }
                
                HStack {
                    TextField(text: $builder.title, prompt: Text(taglist.title)) { EmptyView() }
                        .multilineTextAlignment(.center)
                        .font(F.screenTitle)
                        .disabled(!builder.editing)
                }
                
                ForEach(builder.positiveRules.indices, id: \.self) { index in
                    if index < builder.positiveRules.count {
                        TagRuleField(rule: $builder.positiveRules[index], positive: true, editing: builder.editing)
                    }
                }
                
                if builder.editing && nil == builder.positiveRules.first(where: { $0 == .empty }) {
                    AnimatedButton {
                        builder.positiveRules.append(TagRule(tags: []))
                    } label: {
                        TagRuleField(rule: .constant(.empty), positive: true, editing: false)
                            .opacity(0.3)
                    }
                    .foregroundColor(.primary)
                }
                
                ForEach(builder.negativeRules.indices, id: \.self) { index in
                    if index < builder.negativeRules.count {
                        TagRuleField(rule: $builder.negativeRules[index], positive: false, editing: builder.editing)
                    }
                }
                
                if builder.editing && nil == builder.negativeRules.first(where: { $0 == .empty }) {
                    AnimatedButton {
                        builder.negativeRules.append(TagRule(tags: []))
                    } label: {
                        TagRuleField(rule: .constant(.empty), positive: false, editing: false)
                            .opacity(0.3)
                    }
                    .foregroundColor(.primary)
                }
            
                if builder.editing {
                    HStack {
                        LargeButton(role: .destructive) {
                            if builder.new { 
                                if builder.forTagView {
                                    navigator.settings.navigateBack()
                                } else {
                                    navigator.library.navigateBack()
                                }
                            } else {
                                withAnimation {
                                    builder = TaglistBuilder(taglist, new: builder.new, forTagView: builder.forTagView)
                                }
                            }
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
                        await repository.setActiveTagView(to: builder.asNewTaglist())
                    }
                } label: {
                    Label("Set as active TagView", systemImage: SI.tag)
                }
                
                Button {
                    repository.resetToGlobalTagView()
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
        
        .task { updateSongs() }
        .onChange(of: builder.editing) { updateSongs() }
    }
    
    private func updateSongs() {
        Task.detached(priority: .low) {
            let songs = await builder.builderSongs(from: repository.songs())
            await MainActor.run {
                self.songs = songs
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
                        rule = TagRule(tags: tags)
                    }
            }
        }
        .padding(.horizontal, C.gridPadding)
        .padding(.vertical, 2)
    }
}


    
