//
//  SettingsScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/30/24.
//

import SwiftUI

struct SettingsScreen: View {
    @Environment(\.repository) private var repository
    @Environment(\.preferences) private var preferences
    
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
            }
        }
    }
}

#Preview {
    SettingsScreen()
        .environment(\.repository, PreviewMocks.shared.livePreviewRepository())

}
