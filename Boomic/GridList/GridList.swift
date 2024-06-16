//
//  GridList.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/5/24.
//

import SwiftUI

private typealias C = ViewConstants
private typealias F = ViewConstants.Fonts
private typealias A = ViewConstants.Animations
private typealias SI = ViewConstants.SystemImages

private typealias Config = GridListConfiguration

struct GridList<Icon: View, Menu: View>: View {
    @Environment(\.preferences) private var preferences
    
    let key: String?
    let header: GridListHeader
    let selectable: Bool
    let disabled: Bool
    let title: String
    let titleFont: Font
    let textAlignment: HorizontalAlignment
    let gridEntries: [GridListEntry<Icon, Menu>]
    let showListHeader: Bool
    let hasSubLabels: Bool
    let hasListDividers: Bool
    
    @State private var config: Config
    
    init(
        key: String? = nil
        , config: GridListConfiguration = .threeColumns
        , header: GridListHeader = .standard
        , selectable: Bool = false
        , disabled: Bool = false
        , title: String = "Grid"
        , titleFont: Font = F.sectionTitle
        , textAlignment: HorizontalAlignment = .center
        , showListHeader: Bool = true
        , hasSubLabels: Bool = true
        , hasListDividers: Bool = true
        , entries: [GridListEntry<Icon, Menu>]
    ) {
        self.key = key
        self.config = config
        self.header = header
        self.selectable = selectable
        self.disabled = disabled
        self.title = title
        self.titleFont = titleFont
        self.textAlignment = textAlignment
        self.showListHeader = showListHeader
        self.hasSubLabels = hasSubLabels
        self.hasListDividers = hasListDividers
        self.gridEntries = entries
    }
    
    private var buttonsInToolbar: Bool { header == .buttonsInToolbar && header != .hidden}
    private var buttonsInHeader: Bool { header == .standard }
    private var showHeader: Bool { header != .hidden }
    private var showDividers: Bool { config.listMode && hasListDividers }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if showHeader {
                    HStack {
                        Text(title)
                            .font(titleFont)
                        
                        Spacer()
                        
                        if buttonsInHeader {
                            GridListButtons(config: $config)
                                .font(F.listTitle)
                        }
                    }
                    .padding(C.gridPadding)
                }
                
                LazyVGrid(
                    columns: config.gridMode ? config.columns : Config.oneColumn
                    , alignment: .leading
                    , spacing: 0
                    , pinnedViews: [.sectionHeaders]
                ) {
                    Section(header: GridListSelectorBar(
                        selectable: selectable
                        , localIDs: gridEntries.compactMap({ $0.selectionID })
                        , externalHorizontalPadding: config.externalPadding
                    )) {
                        if showDividers {
                            Divider()
                        }
                        
                        ForEach(gridEntries) { entry in
                            GridListBody(
                                entry: entry
                                , config: config
                                , selectable: selectable
                                , disabled: disabled
                                , textAlignment: textAlignment
                                , showListHeader: showListHeader
                                , hasSubLabels: hasSubLabels
                            )
                            
                            if showDividers { Divider() }
                        }
                    }
                }
                .padding(.horizontal, config.externalPadding)
                
            }
            
                        
            .toolbar {
                if buttonsInToolbar {
                    GridListButtons(config: $config, font: F.toolbarButton)
                }
            }
            
            .task {
                if let key = key {
                    self.config = preferences.loadGrid(key: key, default: config)
                }
            }
            
            .onChange(of: config) {
                if key != nil {
                    preferences.saveGrid(config)
                }
            }
        }
    }
}

struct GridListBody<Icon: View, Menu: View>: View {
    @Environment(\.preferences) private var preferences
    @Environment(\.selector) private var selector
    
    let entry: GridListEntry<Icon, Menu>
    let config: GridListConfiguration
    
    let selectable: Bool
    let disabled: Bool
    let textAlignment: HorizontalAlignment
    let showListHeader: Bool
    let hasSubLabels: Bool
    
    fileprivate init(
        entry: GridListEntry<Icon, Menu>
        , config: Config
        , selectable: Bool
        , disabled: Bool
        , textAlignment: HorizontalAlignment
        , showListHeader: Bool
        , hasSubLabels: Bool
    ) {
        self.entry = entry
        self.config = config
        self.selectable = selectable
        self.disabled = disabled
        self.textAlignment = textAlignment
        self.showListHeader = showListHeader
        self.hasSubLabels = hasSubLabels
    }
    
    private var showIcon: Bool { config.gridMode || config.iconList }
    private var showSubLabel: Bool { hasSubLabels && !config.smallList }
    private func tapToSelect(_ group: SelectionGroup?) -> Bool {
        selectable
        && selector.active
        && group == selector.group
    }
    
    var body: some View {
        ZStack {
            Button {
                if tapToSelect(entry.selectionGroup), let id = entry.selectionID {
                    selector.toggleSelect(id, group: entry.selectionGroup)
                } else {
                    entry.action()
                }
            } label: {
                VStack(alignment: textAlignment) {
                    HStack {
                        if showListHeader && config.listMode, let header = entry.listHeader {
                            Text(header)
                                .font(F.trackNumber)
                                .frame(minWidth: C.songTrackNumberWidth)
                        }
                        
                        if showIcon {
                            entry.icon()
                        }
                        
                        if config.listMode {
                            VStack(alignment: .leading) {
                                Text(entry.label)
                                    .font(config.labelFont)
                                    .lineLimit(1)
                                
                                
                                if showSubLabel, let subLabel = entry.subLabel {
                                    Text(subLabel)
                                        .font(config.subLabelFont)
                                        .lineLimit(1)
                                }
                            }
                            
                            Spacer()
                            
                            if let footer = entry.listFooter {
                                Text(footer)
                                    .font(F.listDuration)
                            }
                        }
                    }
                    .frame(minHeight: config.minHeight, maxHeight: config.maxHeight)
                    
                    if config.showLabels && config.gridMode {
                        VStack(alignment: textAlignment) {
                            Text(entry.label)
                                .font(config.labelFont)
                                .lineLimit(1)
                            
                            if showSubLabel {
                                Text(entry.subLabel ?? " ")
                                    .font(config.subLabelFont)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                .foregroundColor(.primary)
            }
            .disabled(disabled)
            .padding(config.internalPadding)
            .contextMenu { entry.menu() }
            
            if selectable && selector.isSelected(entry.selectionID) {
                Color(preferences.accentColor)
                    .opacity(0.3)
                    .allowsHitTesting(false)
            }
        }
    }
}

extension Config {
    fileprivate var internalPadding: CGFloat {
        if gridMode { return C.gridPadding/2 } // since each grid entry pads itself, use half
        else { return C.gridPadding }
    }
     
    fileprivate var externalPadding: CGFloat {
        if gridMode { return C.gridPadding/2 }
        else { return 0 }
    }
    
    fileprivate var maxHeight: CGFloat {
        if gridMode { return .infinity }
        else if largeIconList { return 100 }
        else if mediumIconList { return 75 }
        else if smallIconList { return C.smallAlbumFrame }
        else if largeList { return C.smallAlbumFrame }
        else if smallList { return C.smallAlbumFrame }
        else { return .infinity }
    }
    
    fileprivate var minHeight: CGFloat {
        if gridMode { return 0 }
        else if largeIconList { return 100 }
        else if mediumIconList { return 75 }
        else if smallIconList { return C.smallAlbumFrame }
        else if largeList { return C.songListEntryMinHeight }
        else if smallList { return 0 }
        else { return .infinity }
    }
    
    fileprivate var labelFont: Font {
        if gridMode {
            if columnCount <= 3 { return F.listTitle }
            else if columnCount > 3 { return F.listEntryTitle }
        }
        else if largeIconList { return F.listTitle }
        else if mediumIconList { return F.listTitle }
        else if smallIconList { return F.listEntryTitle }
        else if largeList { return F.listEntryTitle }
        else if smallList { return F.listEntryTitle }
        
        return F.listTitle
    }
    
    fileprivate var subLabelFont: Font {
        if gridMode {
            if columnCount <= 3 { return F.listSubtitle }
            else if columnCount > 3 { return F.listDuration }
        }
        else if largeIconList { return F.listSubtitle }
        else if mediumIconList { return F.listSubtitle }
        else if smallIconList { return F.listDuration }
        else if largeList { return F.listDuration }
        else if smallList { return F.listDuration }
        
        return F.listTitle
    }
}



#Preview {
    GridList(
        title: "Artists"
        , entries: PreviewMocks.shared.previewArtists().map { artist in
            GridListEntry(
                label: artist.name
                , action: { }
                , icon: {
                    MediaArtView(artist.art)
                        .clipShape(Circle())
                }
                , menu: {
                    List {
                        Text("Hello")
                    }
                }
            )
        }
    )
}
