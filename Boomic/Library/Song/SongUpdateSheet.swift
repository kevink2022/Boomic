//
//  SongUpdate.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/11/24.
//

import SwiftUI
import Models

struct SongUpdateSheet: View {
    let song: Song
    
    @State private var newTitle: String
    @State private var newTrackNumber: String
    
    init(song: Song) {
        self.song = song
        self.newTitle = song.title ?? ""
        self.newTrackNumber = Self.intToString(song.trackNumber)
    }
    
    var body: some View {
        Form {

            Section("Title") {
                TextField(text: $newTitle, prompt: Text(Self.stringToString(song.title))) {
                    Text("Title")
                }
            }
            
            Section("Track Number") {
                TextField(text: $newTrackNumber, prompt: Text(Self.intToString(song.trackNumber))) {
                    Text("Track Number")
                }
            }
        }
    }
    
    static func intToString(_ int: Int?) -> String {
        if let int = int {
            return String(int)
        }
        return ""
    }
    
    static func stringToString(_ string: String?) -> String {
        if let string = string {
            return string
        }
        return ""
    }
}

#Preview {
    SongUpdateSheet(song: PreviewMocks.shared.previewSong())
}
