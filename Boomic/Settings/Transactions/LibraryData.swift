//
//  LibraryData.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/8/24.
//

import SwiftUI
import Database
import Storage

struct LibraryData: View {
    @Environment(\.navigator) private var navigator
    @Environment(\.repository) private var repository
    
    @State var libraryDataSize: String = ""
    @State var libraryDataAllocatedSize: String = ""

    @State var libraryFileSize: String = ""
    @State var libraryFileAllocatedSize: String = ""
    
    var body: some View {
        List {
            Section("Local Media") {
                Text("Total Size: \(libraryFileSize)")
                Text("Allocated Space: \(libraryFileAllocatedSize)")
            }
            
            Section("Library Data") {
                Text("Total Size: \(libraryDataSize)")
                Text("Allocated Space: \(libraryDataAllocatedSize)")
            }
            
            Section {
                Button {
                    Task { await repository.exportTransactionHistory() }
                } label: {
                    Text("Export Library History")
                }
                
                Button {
                    navigator.showFilePicker(for: [.json]) { result in
                        switch result {
                        case .failure(let error):
                            print("error: \(error.localizedDescription)")
                        case .success(let urls):
                            guard let url = urls.first else { return }
                            Task {
                                await repository.importTransactionHistory(from: url)
                            }
                        }
                        
                    }
                } label: {
                    Text("Import Library History")
                }
            }
            
            Section {
                Button {
                    createReadMe()
                } label: {
                    Text("Create README.txt")
                }
                
                Button(role: .destructive) {
                    
                } label: {
                    Text("Delete Library Data")
                }
            }
        }
        
        .task {
            (libraryDataSize, libraryDataAllocatedSize) = await repository.libraryDataSizeAndAllocatedSize()
            
            (libraryFileSize, libraryFileAllocatedSize) = await repository.libraryFilesSizeAndAllocatedSize()
        }        
    }
    
    private func createReadMe() {
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
    LibraryData()
        .environment(\.repository, PreviewMocks.shared.livePreviewRepository())
}
