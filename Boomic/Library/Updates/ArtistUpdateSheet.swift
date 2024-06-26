//
//  ArtistUpdateSheet.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/15/24.
//

import SwiftUI
import Models

private typealias F = ViewConstants.Fonts
private typealias SI = ViewConstants.SystemImages

struct ArtistUpdateSheet: View {
    @Environment(\.navigator) private var navigator
    @Environment(\.repository) private var repository
    
    @State private var model: ArtistUpdateViewModel
    
    init(artists: Set<Artist>) {
        self.model = ArtistUpdateViewModel(artists: artists)
    }
    
    private func rated(_ star: Int) -> Bool { model.data.working.rating ?? 0 >= star }
    private var singleArtist: Artist { model.artists.first ?? Artist.none }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    if model.multiEdit {
                        Text("Editing \(model.artists.count) Artists")
                            .font(F.listTitle)
                    } else {
                        Text(singleArtist.name)
                            .font(F.listTitle)
                    }
                    
                    LargeButton {
                        Task {
                            navigator.dismissSheet()
                            let updates = model.generateUpdates()
                            await repository.updateArtists(Set(updates))
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
                    Section("Name") {
                        TextField(text: $model.data.working.title, prompt: Text(model.data.base.title)) { EmptyView() }
                    }
                }
                
                Section("Cover") {
                    MediaArtEditor($model.data.working.art, editing: true, aspectRatio: .fit, cornerRadius: 500)
                        .padding(.horizontal, 30)
                }
            }
        }
    }
}

@Observable
fileprivate final class ArtistUpdateViewModel {
    let artists: Set<Artist>
    var data: WorkingSheetData
    
    var multiEdit: Bool { artists.count > 1 }
    var willModify: Bool { data.willModify }
    
    init(artists: Set<Artist>) {
        let first = artists.first ?? Artist.none
        var constructor = SheetData(artist: first)
        
        artists.forEach { artist in
            constructor.add(artist: artist)
        }
        
        self.artists = artists
        self.data = WorkingSheetData(
            working: constructor
            , base: constructor
        )
    }
    
    func generateUpdates() -> [ArtistUpdate] {
        return artists.map { data.asArtistUpdate(on: $0, multiEdit: multiEdit) }
    }
}

#Preview {
    ArtistUpdateSheet(artists: [PreviewMocks.shared.previewArtist()])
}
