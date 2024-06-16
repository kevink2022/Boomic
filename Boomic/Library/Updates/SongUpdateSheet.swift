//
//  SongUpdate.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/11/24.
//

import SwiftUI
import Models

private typealias F = ViewConstants.Fonts
private typealias SI = ViewConstants.SystemImages

struct SongUpdateSheet: View {
    @Environment(\.navigator) private var navigator
    @Environment(\.repository) private var repository
    
    @State private var model: SongUpdateViewModel
    
    init(songs: Set<Song>) {
        self.model = SongUpdateViewModel(songs: songs)
    }
    
    private func rated(_ star: Int) -> Bool { model.data.working.rating ?? 0 >= star }
    private var singleSong: Song { model.songs.first ?? Song.none }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    if model.multiEdit {
                        Text("Editing \(model.songs.count) songs")
                            .font(F.listTitle)
                    } else {
                        Text(singleSong.label)
                            .font(F.listTitle)
                        Text("\(singleSong.source.label)")
                    }
                    
                    HStack {
                        ForEach(1...5, id: \.self) { star in
                            Button {
                                if rated(star) {
                                    model.data.working.rating = model.data.working.rating ?? 1 - 1
                                } else {
                                    model.data.working.rating = star
                                }
                            } label: {
                                Image(systemName: rated(star) ? SI.rated : SI.unrated)
                            }
                        }
                    }
                    
                    LargeButton {
                        Task {
                            navigator.dismissSheet()
                            let updates = model.generateUpdates()
                            await repository.updateSongs(Set(updates))
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
                    
                    Section("Track Number") {
                        TextField(text: $model.data.working.trackNumber, prompt: Text(model.data.base.trackNumber)) { EmptyView() }
                    }
                    .keyboardType(.numberPad)
                }
                
                Section("Disc Number") {
                    TextField(text: $model.data.working.discNumber, prompt: Text(model.data.base.discNumber)) { EmptyView() }
                }
                .keyboardType(.numberPad)
                
                Section("Artist Name") {
                    TextField(text: $model.data.working.artistName, prompt: Text(model.data.base.artistName)) { EmptyView() }
                }
                
                Section("Album Title") {
                    TextField(text: $model.data.working.albumTitle, prompt: Text(model.data.base.albumTitle)) { EmptyView() }
                }
            }
        }
    }
}

@Observable
fileprivate final class SongUpdateViewModel {
    let songs: Set<Song>
    var data: WorkingSheetData
    
    var multiEdit: Bool { songs.count > 1 }
    var willModify: Bool { data.willModify }
    
    init(songs: Set<Song>) {
        let first = songs.first ?? Song.none
        var constructor = SheetData(song: first)
        
        songs.forEach { song in
            constructor.add(song: song)
        }
        
        self.songs = songs
        self.data = WorkingSheetData(
            working: constructor
            , base: constructor
        )
    }
    
    func generateUpdates() -> [SongUpdate] {
        return songs.map { data.asSongUpdate(on: $0, multiEdit: multiEdit) }
    }
}


#Preview {
    Text("Hello World")
        .sheet(isPresented: .constant(true), content: {
            SongUpdateSheet(songs: [PreviewMocks.shared.previewSong()])
        })
    
}
