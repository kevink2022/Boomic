//
//  SettingsScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/30/24.
//

import SwiftUI
import Models // DEBUG

struct SettingsScreen: View {
    @Environment(\.repository) private var repository
    @Environment(\.preferences) private var preferences
    
    @State private var importStatus: String = ""
    private var importInProgress: Bool {
        repository.statusActive(for: .importSongs)
    }
    
    var body: some View {
        @Bindable var preferences = preferences
        
        NavigationStack {
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
                    NavigationLink {
                        LibraryData()
                    } label: {
                        Text("Manage Library Data")
                    }
                    
                    NavigationLink {
                        TransactionsList()
                    } label: {
                        Text("Library Change History")
                    }
                }  header: {
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
                    NavigationLink {
                        AccentColorPicker()
                    } label: {
                        Text("Accent Color")
                    }
                    
                    NavigationLink {
                        TabOrder()
                    } label: {
                        Text("Tab Order")
                    }
                    
                    NavigationLink {
                        LibraryPanelOrder()
                    } label: {
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
                                .map { SongUpdate(song: $0, tags: [Tag.from("#mario")!]) }
                            print(marioUpdates.count)
                            await repository.updateSongs(Set(marioUpdates))
                        }
                    } label: {
                        Text("Add Mario Tags")
                    }
                }
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
