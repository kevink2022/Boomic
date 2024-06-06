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
                        Task { await repository.addSongs([]) }
                    } label: {
                        Text("Import Songs")
                    }
                }
                
                Section("Libary Data") {
                    NavigationLink {
                        TransactionsList()
                    } label: {
                        Text("Library Transactions")
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
                
                Section("Debug") {
                    Button {
                        createReadMe()
                    } label: {
                        Text("Create README.txt")
                    }
                }
            }
        }
    }
    
    func createReadMe() {
        let file = "README.txt"
        let contents = "Idk why I still need to do this"
        
        let dir = URL.documentsDirectory
        let fileURL = dir.appending(component: file)
        
        do {
            try contents.write(to: fileURL, atomically: false, encoding: .utf8)
        }
        catch { }
    }
}

#Preview {
    SettingsScreen()
        .environment(\.repository, PreviewMocks.shared.livePreviewRepository())

}
