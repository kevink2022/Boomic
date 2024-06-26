//
//  AlbumUpdateSheet.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/15/24.
//

import SwiftUI
import Models

private typealias C = ViewConstants
private typealias F = ViewConstants.Fonts
private typealias SI = ViewConstants.SystemImages

struct AlbumUpdateSheet: View {
    @Environment(\.navigator) private var navigator
    @Environment(\.repository) private var repository
    
    @State private var model: AlbumUpdateViewModel
    
    init(albums: Set<Album>) {
        self.model = AlbumUpdateViewModel(albums: albums)
    }
    
    private func rated(_ star: Int) -> Bool { model.data.working.rating ?? 0 >= star }
    private var singleAlbum: Album { model.albums.first ?? Album.none }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    if model.multiEdit {
                        Text("Editing \(model.albums.count) Albums")
                            .font(F.listTitle)
                    } else {
                        Text(singleAlbum.title)
                            .font(F.listTitle)
                    }
                    
                    LargeButton {
                        Task {
                            navigator.dismissSheet()
                            let updates = model.generateUpdates()
                            await repository.updateAlbums(Set(updates))
                        }
                    } label: {
                        Text("Save Changes")
                    }
                    .disabled(!model.willModify)
                    .frame(height: 50)

                }
                .padding(20)
                
                Spacer()
            }
            
            Divider()
            
            Form {
                if !model.multiEdit {
                    Section("Title") {
                        TextField(text: $model.data.working.title, prompt: Text(model.data.base.title)) { EmptyView() }
                    }
                }
                
                Section("Artist Name") {
                    TextField(text: $model.data.working.artistName, prompt: Text(model.data.base.artistName)) { EmptyView() }
                }
                
                Section("Cover") {
                    MediaArtEditor($model.data.working.art, editing: true, aspectRatio: .fit, cornerRadius: C.albumCornerRadius)
                        .padding(.horizontal, 30)
                    
                    Toggle(isOn: .constant(false)) {
                        Text("Apply to Album Songs?")
                    }
                    .disabled(model.data.working.art == model.data.base.art)
                }
            }
        }
    }
}

@Observable
fileprivate final class AlbumUpdateViewModel {
    let albums: Set<Album>
    var data: WorkingSheetData
    
    var multiEdit: Bool { albums.count > 1 }
    var willModify: Bool { data.willModify }
    
    init(albums: Set<Album>) {
        let first = albums.first ?? Album.none
        var constructor = SheetData(album: first)
        
        albums.forEach { album in
            constructor.add(album: album)
        }
        
        self.albums = albums
        self.data = WorkingSheetData(
            working: constructor
            , base: constructor
        )
    }
    
    func generateUpdates() -> [AlbumUpdate] {
        return albums.map { data.asAlbumUpdate(on: $0, multiEdit: multiEdit) }
    }
}

#Preview {
    AlbumUpdateSheet(albums: [PreviewMocks.shared.previewAlbum()])
}
