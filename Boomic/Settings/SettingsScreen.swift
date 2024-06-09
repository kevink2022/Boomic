//
//  SettingsScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/30/24.
//

import SwiftUI

struct SettingsScreen: View {
    @Environment(\.repository) var repository
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        Task { await repository.importSongs() }
                    } label: {
                        Text("Import Songs")
                    }
                }
                
                Section("Libary Data") {
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
                }
                
                Section("UI Preferences") {
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
                }
            }
        }
    }
}

#Preview {
    SettingsScreen()
        .environment(\.repository, PreviewMocks.shared.livePreviewRepository())

}
