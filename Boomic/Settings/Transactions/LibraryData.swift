//
//  LibraryData.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/8/24.
//

import SwiftUI

struct LibraryData: View {
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
}

#Preview {
    LibraryData()
        .environment(\.repository, PreviewMocks.shared.livePreviewRepository())
}
