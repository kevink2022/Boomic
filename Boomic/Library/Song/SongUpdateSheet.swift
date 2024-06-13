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

private typealias SheetData = SongUpdateSheetData

struct SongUpdateSheet: View {
    let song: Song
    @State private var data: SheetData
    
    init(song: Song) {
        self.song = song
        self.data = SheetData(song: song)
    }
    
    private func rated(_ star: Int) -> Bool { data.rating ?? 0 >= star }
    private var willModify: Bool {
        data.asUpdate().willModify(song)
    }
     
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text(data.song.label)
                        .font(F.listTitle)
                    Text("\(data.song.source.label)")
                    
                    HStack {
                        ForEach(1...5, id: \.self) { star in
                            Button {
                                if rated(star) {
                                    data.rating = data.rating ?? 1 - 1
                                } else {
                                    data.rating = star
                                }
                            } label: {
                                Image(systemName: rated(star) ? SI.rated : SI.unrated)
                            }
                        }
                    }
                    
                    LargeButton {
                        
                    } label: {
                        Text("Save Changes")
                    }
                    .disabled(!willModify)
                    .frame(height: 50)

                }
                .padding(20)
                
                Spacer()
            }
            
            Divider()
            
            Form {
                Section("Title") {
                    TextField(text: $data.title, prompt: Text(UpdateSheet.toSheet(song.title))) { EmptyView() }
                }
                
                Section("Track Number") {
                    TextField(text: $data.trackNumber, prompt: Text(UpdateSheet.toSheet(song.trackNumber))) { EmptyView() }
                }
                
                Section("Disc Number") {
                    TextField(text: $data.discNumber, prompt: Text(UpdateSheet.toSheet(song.discNumber))) { EmptyView() }
                }
                
                Section("Artist Name") {
                    TextField(text: $data.artistName, prompt: Text(UpdateSheet.toSheet(song.artistName))) { EmptyView() }
                }
                
                Section("Album Title") {
                    TextField(text: $data.albumTitle, prompt: Text(UpdateSheet.toSheet(song.albumTitle))) { EmptyView() }
                }
            }
        }
    }
}

class UpdateSheet {
    static func toSheet(_ int: Int?) -> String {
        if let int = int { return String(int) }
        return ""
    }
    
    static func fromSheet(_ string: String) -> Int? {
        if string == "" { return nil }
        return Int(string)
    }
    
    static func toSheet(_ string: String?) -> String {
        if let string = string { return string }
        return ""
    }
    
    static func fromSheet(_ string: String) -> String? {
        if string == "" { return nil }
        return string
    }
}

@Observable
fileprivate final class SongUpdateSheetData: UpdateSheet {
    let song: Song
    
    var title: String
    var trackNumber: String
    var discNumber: String
    
    var artistName: String
    var albumTitle: String
    var rating: Int? { didSet { if rating == 0 {rating = nil} } }
    
    var art: MediaArt?
    
    init(song: Song) {
        self.song = song
        self.title = Self.toSheet(song.title)
        self.trackNumber = Self.toSheet(song.trackNumber)
        self.discNumber = Self.toSheet(song.discNumber)
        self.art = song.art
        self.artistName = Self.toSheet(song.artistName)
        self.albumTitle = Self.toSheet(song.albumTitle)
        self.rating = song.rating
    }
    
    func asUpdate() -> SongUpdate {
        var erasing = Set<PartialKeyPath<Song>>()
        
        if song.title != nil && title == "" { erasing.insert(\.title) }
        if song.trackNumber != nil && trackNumber == "" { erasing.insert(\.trackNumber) }
        if song.discNumber != nil && discNumber == "" { erasing.insert(\.discNumber) }
        if song.art != nil && art == nil { erasing.insert(\.title) }
        if song.artistName != nil && artistName == "" { erasing.insert(\.artistName) }
        if song.albumTitle != nil && albumTitle == "" { erasing.insert(\.albumTitle) }
        if song.rating != nil && rating == nil { erasing.insert(\.title) }
        
        let update =  SongUpdate(
            song: song
            , title: song.title != Self.fromSheet(title) ? Self.fromSheet(title) : nil
            , trackNumber: song.trackNumber != Self.fromSheet(trackNumber) ? Self.fromSheet(trackNumber) : nil
            , discNumber: song.discNumber != Self.fromSheet(discNumber) ? Self.fromSheet(discNumber) : nil
            , art: song.art != art ? art : nil
            , artistName: song.artistName != Self.fromSheet(artistName) ? Self.fromSheet(artistName) : nil
            , albumTitle: song.albumTitle != Self.fromSheet(albumTitle) ? Self.fromSheet(albumTitle) : nil
            , rating: song.rating != rating ? rating : nil
        )
        
        return update
    }
}

#Preview {
    Text("Hello World")
        .sheet(isPresented: .constant(true), content: {
            SongUpdateSheet(song: PreviewMocks.shared.previewSong())
        })
    
}
