//
//  AddDetailsScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/14/24.
//

import SwiftUI
import Database
import Models

private typealias C = ViewConstants
private typealias F = ViewConstants.Fonts

struct SongAddDetailsScreen: View {
    let model: Song
    let timestamp: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading) {
                Text("Add Song: \(model.label)")
                    .font(F.listEntryTitle)
                Text(timestamp.shortFormatted)
                    .font(F.body)
                    .opacity(0.6)
            }
            .padding(C.screenTitlePadding)
            
            List {
                Text("Source: \(model.source.label)")
                Text("Duration: \(model.duration.formatted)")
                if let title = model.title { Text("Title: \(title)") }
                if let trackNumber = model.trackNumber { Text("Track Number: \(trackNumber)") }
                if let discNumber = model.discNumber { Text("Disc Number: \(discNumber)") }
                if let artistName = model.artistName {
                    Text("Artist Name: \(artistName)")
                    Text("Linked Artist Count: \(model.artists.count)")
                }
                if let albumTitle = model.albumTitle {
                    Text("Album Title: \(albumTitle)")
                    Text("Linked Album Count: \(model.albums.count)")
                }
                if let art = model.art { Text("Art Location: \(art.label)") }
            }
        }
    }
}

struct AlbumAddDetailsScreen: View {
    let model: Album
    let timestamp: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading) {
                Text("Add Album: \(model.title)")
                    .font(F.listEntryTitle)
                Text(timestamp.shortFormatted)
                    .font(F.body)
                    .opacity(0.6)
            }
            .padding(C.screenTitlePadding)

            List {
                Text("Title: \(model.title)")
                Text("Linked Song Count: \(model.songs.count)")
                if let artistName = model.artistName {
                    Text("Artist Name: \(artistName)")
                    Text("Linked Artist Count: \(model.artists.count)")
                }
                if let art = model.art { Text("Art Location: \(art.label)") }
            }
        }
    }
}

struct ArtistAddDetailsScreen: View {
    let model: Artist
    let timestamp: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading) {
                Text("Add Artist: \(model.name)")
                    .font(F.listEntryTitle)
                Text(timestamp.shortFormatted)
                    .font(F.body)
                    .opacity(0.6)
            }
            .padding(C.screenTitlePadding)

            List {
                Text("Name: \(model.name)")
                Text("Linked Song Count: \(model.songs.count)")
                Text("Linked Album Count: \(model.albums.count)")
                if let art = model.art { Text("Art Location: \(art.label)") }
            }
        }
    }
}

struct SongUpdateDetailsScreen: View {
    let model: SongUpdate
    let timestamp: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading) {
                Text("Update Song: \(model.label)")
                    .font(F.listEntryTitle)
                Text(timestamp.shortFormatted)
                    .font(F.body)
                    .opacity(0.6)
            }
            .padding(C.screenTitlePadding)

            List {
                if let title = model.title { Text("Title updated to: \(title)") }
                if let trackNumber = model.trackNumber { Text("Track Number updated to: \(trackNumber)") }
                if let discNumber = model.discNumber { Text("Disc Number updated to: \(discNumber)") }
                if let artistName = model.artistName { Text("Artist Name updated to: \(artistName)") }
                if let artists = model.artists { Text("Linked Artist Count updated to: \(artists.count)")  }
                if let albumTitle = model.albumTitle { Text("Album Title updated to: \(albumTitle)") }
                if let albums = model.albums { Text("Linked Album Count updated to: \(albums.count)") }
                if let art = model.art { Text("Art Location updated to: \(art.label)") }
                if let rating = model.rating { Text("Rating updated to: \(rating)") }
            }
        }
    }
}

struct AlbumUpdateDetailsScreen: View {
    let model: AlbumUpdate
    let timestamp: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading) {
                Text("Update Album: \(model.originalTitle)")
                    .font(F.listEntryTitle)
                Text(timestamp.shortFormatted)
                    .font(F.body)
                    .opacity(0.6)
            }
            .padding(C.screenTitlePadding)

            List {
                if let newTitle = model.newTitle { Text("Title updated to: \(newTitle) (from \(model.originalTitle))") }
                if let songs = model.songs { Text("Linked Song Count updated to: \(songs.count)") }
                if let artistName = model.artistName { Text("Artist Name updated to: \(artistName)") }
                if let artists = model.artists { Text("Linked Artist Count updated to: \(artists.count)") }
                if let art = model.art { Text("Art Location updated to: \(art.label)") }
            }
        }
    }
}

struct ArtistUpdateDetailsScreen: View {
    let model: ArtistUpdate
    let timestamp: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading) {
                Text("Update Artist: \(model.originalName)")
                    .font(F.listEntryTitle)
                Text(timestamp.shortFormatted)
                    .font(F.body)
                    .opacity(0.6)
            }
            .padding(C.screenTitlePadding)

           List {
               if let newName = model.newName { Text("Name updated to: \(newName) (from \(model.originalName))") }
               if let songs = model.songs { Text("Linked Song Count updated to: \(songs.count)") }
               if let albums = model.albums { Text("Linked Album Count updated to: \(albums.count)") }
               if let art = model.art { Text("Art Location updated to: \(art.label)") }
           }
       }
    }
}

struct DeleteAssertionDetailsScreen: View {
    let model: DeleteAssertion
    let timestamp: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Delete \(model.model.label): \(model.label)")
                        .font(F.listEntryTitle)
                    Text(timestamp.shortFormatted)
                        .font(F.body)
                        .opacity(0.6)
                }
                
                Spacer()
            }
            .padding(C.screenTitlePadding)
            
            Spacer()
       }
    }
}

extension AssertionModel {
    var label: String {
        switch self {
        case .song: "Song"
        case .album: "Album"
        case .artist: "Artist"
        }
    }
}

//#Preview {
//    AddDetailsScreen()
//}
