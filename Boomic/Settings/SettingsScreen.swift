//
//  SettingsScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/30/24.
//

import SwiftUI
import Models // DEBUG

struct SettingsScreen: View {
    @Environment(\.navigator) private var navigator
    @Environment(\.preferences) private var preferences
    @Environment(\.repository) private var repository
    
    @State private var importStatus: String = ""
    private var importInProgress: Bool {
        repository.statusActive(for: .importSongs)
    }
    
    var body: some View {
        @Bindable var preferences = preferences
        @Bindable var navigator = navigator

        
        NavigationStack(path: $navigator.settings) {
            List {
                Section {
                    Button {
                        Task { await repository.importSongs() }
                    } label: {
                        Text("Import Songs")
                    }
                    .disabled(importInProgress)
                } footer: {
                    if importInProgress {
                        HStack(spacing: 10) {
                            ProgressView()
                            Text(importStatus)
                        }
                    }
                }
                
                Section {
                    NavigationLink(value: SettingsNavigation.tagViews ) {
                        Text("TagViews")
                    }
                    
                    NavigationLink(value: SettingsNavigation.libraryData) {
                        Text("Manage Library Data")
                    }
                    
                    NavigationLink(value: SettingsNavigation.transactionList) {
                        Text("Library Change History")
                    }
                } header: {
                    Text("Libary Data")
                }
                
                Section {
                    Toggle(isOn: $preferences.localSearchOnlyPrimary) {
                        Text("Local Search by Title Only")
                    }
                } header: {
                    Text("Search")
                } footer: {
                    Text("Limit searches to only the title/name of the object. Does not apply to global search.")
                }
                
                Section {
                    NavigationLink(value: SettingsNavigation.accentColorPicker) {
                        Text("Accent Color")
                    }
                    
                    NavigationLink(value: SettingsNavigation.tabOrder) {
                        Text("Tab Order")
                    }
                    
                    NavigationLink(value: SettingsNavigation.libararyPanelOrder) {
                        Text("Library Panel Order")
                    }
                } header: {
                    Text("UI Preferences")
                }
                
                Section("Debug") {
                    Button {
                        Task {
                            let marioUpdates = repository.songs()
                                .search("Mario")
                                .map { SongUpdate(song: $0, tags: [Tag.from("#MARIO")!]) }
                            await repository.updateSongs(Set(marioUpdates))
                        }
                    } label: {
                        Text("Add Mario Tags")
                    }
                }
            }
            .navigationDestination(for: SettingsNavigation.self) { destination in
                switch destination {
                case .accentColorPicker: AccentColorPicker()
                case .libararyPanelOrder: LibraryPanelOrder()
                case .libraryData: LibraryData()
                case .newTagView: TaglistScreen(taglist: nil, forTagView: true)
                case .tabOrder: TabOrder()
                case .tagViews : TagViewsScreen()
                case .transactionList: TransactionsList()
                }
            }
            .navigationDestination(for: Taglist.self) { taglist in
                TaglistScreen(taglist: taglist, forTagView: true)
            }
        }
        

        .onChange(of: repository.status) {
            if repository.status.key == .importSongs {
                importStatus = repository.status.message
            }
        }
    }
}

#Preview {
    SettingsScreen()
        .environment(\.repository, PreviewMocks.shared.livePreviewRepository())

}
