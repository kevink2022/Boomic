//
//  SongUpdate.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/11/24.
//

import SwiftUI
import Models

private typealias SheetData = SongUpdateSheetData

struct SongUpdateSheet: View {
    let song: Song
    
    @State private var newTitle: String
//    @State private var newTrackNumber: String
    
    @State private var data: SheetData
    
    init(song: Song) {
        self.song = song
        self.newTitle = song.title ?? ""
//        self.newTrackNumber = Self.intToString(song.trackNumber)
        self.data = SheetData(song: song)
    }
     
    var body: some View {
        Form {
            Text(data.song.label)
            Text("\(data.song.source)")

            Section("Title") {
                TextField(text: $data.title, prompt: Text(song.title ?? "")) {
                    Text("Title")
                }
            }
            
//            Section("Track Number") {
//                TextField(text: $newTrackNumber, prompt: Text(Self.intToString(song.trackNumber))) {
//                    Text("Track Number")
//                }
//            }
        }
    }
    
    
}

fileprivate final class SongUpdateSheetData {
    let song: Song
    
    var title: String
    var trackNumber: String
    var discNumber: String
    
    var artistName: String
    var albumTitle: String
    var rating: String
    
    var art: MediaArt?
    
    init(song: Song) {
        self.song = song
        self.title = Self.toString(song.title)
        self.trackNumber = Self.toString(song.trackNumber)
        self.discNumber = Self.toString(song.discNumber)
        self.art = song.art
        self.artistName = Self.toString(song.artistName)
        self.albumTitle = Self.toString(song.albumTitle)
        self.rating = Self.toString(song.rating)
    }
    
    static func toString(_ int: Int?) -> String {
        if let int = int {
            return String(int)
        }
        return ""
    }
    
    static func toString(_ string: String?) -> String {
        if let string = string {
            return string
        }
        return ""
    }
}

#Preview {
    Text("Hello World")
        .sheet(isPresented: .constant(true), content: {
            SongUpdateSheet(song: PreviewMocks.shared.previewSong())
        })
    
}
