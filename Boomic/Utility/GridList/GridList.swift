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

struct GridListEntry<Icon: View>: Identifiable {
    let id = UUID()
    let label: String
    let subLabel: String?
    let action: () -> ()
    let icon: () -> Icon
    
    init(
        label: String
        , subLabel: String? = nil
        , action: (() -> ())?
        , @ViewBuilder icon: @escaping () -> Icon
    ) {
        self.label = label
        self.subLabel = subLabel
        self.action = action ?? {}
        self.icon = icon
    }
}

struct GridList<Icon: View>: View {
    @Environment(\.preferences) private var preferences
    
    let title: String
    let key: String?
    let titleFont: Font
    let textAlignment: HorizontalAlignment
    let buttonsInToolbar: Bool
    let gridEntries: [GridListEntry<Icon>]
        
    init(title: String
         , key: String? = nil
         , titleFont: Font = F.sectionTitle
         , textAlignment: HorizontalAlignment = .center
         , buttonsInToolbar: Bool = false
         , entries: [GridListEntry<Icon>]
    ) {
        self.title = title
        self.key = key
        self.titleFont = titleFont
        self.textAlignment = textAlignment
        self.buttonsInToolbar = buttonsInToolbar
        self.gridEntries = entries
        self.config = Config.standard
    }
    
    @State private var config: Config
    
    var body: some View {
        ScrollView {
            HStack {
                Text(title)
                    .font(titleFont)
 
                Spacer()
                
                if !buttonsInToolbar {
                    GridListButtons(config: $config)
                        .font(F.listTitle)
                }
            }
            
            if config.listMode { Divider() }

            LazyVGrid(
                columns: config.gridMode ? config.columns : Config.oneColumn
                , alignment: .leading
            ) {
                ForEach(gridEntries) { entry in
                    Button {
                        entry.action()
                    } label: {
                        VStack(alignment: textAlignment) {
                            HStack {
                                entry.icon()
                                
                                if config.listMode {
                                    VStack(alignment: .leading) {
                                        Text(entry.label)
                                            .font(F.listTitle)
                                            .lineLimit(1)
                                        
                                        if let subLabel = entry.subLabel {
                                            Text(subLabel)
                                                .font(F.listSubtitle)
                                                .lineLimit(1)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                            }
                            .frame(maxHeight: config.frame())
                            
                            if config.listMode {
                                Divider()
                            } else if config.showLabels && config.gridMode {
                                Text(entry.label)
                                    .font(F.listTitle)
                                    .lineLimit(1)
                                
                                if let subLabel = entry.subLabel {
                                    Text(subLabel)
                                        .font(F.listSubtitle)
                                        .lineLimit(1)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
            
            .toolbar {
                if buttonsInToolbar {
                    GridListButtons(config: $config, font: F.toolbarButton)
                }
            }
            
            .task {
                if let key = key {
                    self.config = preferences.loadGrid(key: key)
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

extension Config {
    func frame() -> CGFloat {
        if gridMode { return .infinity }
        else if largeList { return 150 }
        else if mediumList { return 100 }
        else if smallList { return C.smallAlbumFrame }
        else { return .infinity }
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
            )
        }
    )
}
