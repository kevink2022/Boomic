//
//  TransactionAssertionsScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/6/24.
//

import SwiftUI
import Database
import Models

private typealias F = ViewConstants.Fonts

struct TransactionAssertionsScreen: View {
    let transaction: DataTransaction<LibraryTransaction>
    private let padding: CGFloat = 20
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading) {
                Text(transaction.data.label)
                    .font(F.listEntryTitle)
                Text(transaction.timestamp.shortFormatted)
                    .font(F.body)
                    .opacity(0.6)
            }
            .padding(padding)
            
            List {
                ForEach(transaction.data.assertions.values) { assertion in
                    switch assertion {
                    case .addSong(let model):
                        NavigationLink {
                            VStack(alignment: .leading, spacing: 0) {
                                VStack(alignment: .leading) {
                                    Text("Add Song: \(model.label)")
                                        .font(F.listEntryTitle)
                                    Text(transaction.timestamp.shortFormatted)
                                        .font(F.body)
                                        .opacity(0.6)
                                }
                                .padding(padding)

                                List {
                                    Text("Source:\(model.source)")
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
                                    if let art = model.art { Text("Art Location: \(art)") }
                                }
                            }
                        } label: {
                            Text("Add Song: \(model.label)")
                        }
                        
                    case .addAlbum(let model):
                        NavigationLink {
                            VStack(alignment: .leading, spacing: 0) {
                                VStack(alignment: .leading) {
                                    Text("Add Album: \(model.title)")
                                        .font(F.listEntryTitle)
                                    Text(transaction.timestamp.shortFormatted)
                                        .font(F.body)
                                        .opacity(0.6)
                                }
                                .padding(padding)
                                
                                List {
                                    Text("Title: \(model.title)")
                                    Text("Linked Song Count: \(model.songs.count)")
                                    if let artistName = model.artistName {
                                        Text("Artist Name: \(artistName)")
                                        Text("Linked Artist Count: \(model.artists.count)")
                                    }
                                    if let art = model.art { Text("Art Location: \(art)") }
                                }
                            }
                        } label: {
                            Text("Add Album: \(model.title)")
                        }
                        
                    case .addArtist(let model):
                        NavigationLink {
                            VStack(alignment: .leading, spacing: 0) {
                                VStack(alignment: .leading) {
                                    Text("Add Artist: \(model.name)")
                                        .font(F.listEntryTitle)
                                    Text(transaction.timestamp.shortFormatted)
                                        .font(F.body)
                                        .opacity(0.6)
                                }
                                .padding(padding)

                                List {
                                    Text("Name: \(model.name)")
                                    Text("Linked Song Count: \(model.songs.count)")
                                    Text("Linked Album Count: \(model.albums.count)")
                                    if let art = model.art { Text("Art Location: \(art)") }
                                }
                            }
                        } label: {
                            Text("Add Artist: \(model.name)")
                        }
                    case .updateSong(let model):
                        NavigationLink {
                            VStack(alignment: .leading, spacing: 0) {
                                VStack(alignment: .leading) {
                                    Text("Update Song: \(model.label)")
                                        .font(F.listEntryTitle)
                                    Text(transaction.timestamp.shortFormatted)
                                        .font(F.body)
                                        .opacity(0.6)
                                }
                                .padding(padding)
                                
                                List {
                                    if let title = model.title { Text("Title updated to: \(title)") }
                                    if let trackNumber = model.trackNumber { Text("Track Number updated to: \(trackNumber)") }
                                    if let discNumber = model.discNumber { Text("Disc Number updated to: \(discNumber)") }
                                    if let artistName = model.artistName { Text("Artist Name updated to: \(artistName)") }
                                    if let artists = model.artists { Text("Linked Artist Count updated to: \(artists.count)")  }
                                    if let albumTitle = model.albumTitle { Text("Album Title updated to: \(albumTitle)") }
                                    if let albums = model.albums { Text("Linked Album Count updated to: \(albums.count)") }
                                    if let art = model.art { Text("Art Location updated to: \(art)") }
                                    if let rating = model.rating { Text("Rating updated to: \(rating)") }
                                }
                            }
                        } label: {
                            Text("Update Song: \(model.label)")
                        }
                            
                    case .updateAlbum(let model):
                        NavigationLink {
                            VStack(alignment: .leading, spacing: 0) {
                                VStack(alignment: .leading) {
                                    Text("Update Album: \(model.originalTitle)")
                                        .font(F.listEntryTitle)
                                    Text(transaction.timestamp.shortFormatted)
                                        .font(F.body)
                                        .opacity(0.6)
                                }
                                .padding(padding)
                                
                                List {
                                    if let newTitle = model.newTitle { Text("Title updated to: \(newTitle) (from \(model.originalTitle))") }
                                    if let songs = model.songs { Text("Linked Song Count updated to: \(songs.count)") }
                                    if let artistName = model.artistName { Text("Artist Name updated to: \(artistName)") }
                                    if let artists = model.artists { Text("Linked Artist Count updated to: \(artists.count)") }
                                    if let art = model.art { Text("Art Location updated to: \(art)") }
                                }
                            }
                        } label: {
                            Text("Update Album: \(model.originalTitle)")
                        }
                        
                    case .updateArtist(let model):
                        NavigationLink {
                            VStack(alignment: .leading, spacing: 0) {
                                VStack(alignment: .leading) {
                                    Text("Update Artist: \(model.originalName)")
                                        .font(F.listEntryTitle)
                                    Text(transaction.timestamp.shortFormatted)
                                        .font(F.body)
                                        .opacity(0.6)
                                }
                                .padding(padding)
                               
                               List {
                                   if let newName = model.newName { Text("Name updated to: \(newName) (from \(model.originalName))") }
                                   if let songs = model.songs { Text("Linked Song Count updated to: \(songs.count)") }
                                   if let albums = model.albums { Text("Linked Album Count updated to: \(albums.count)") }
                                   if let art = model.art { Text("Art Location updated to: \(art)") }
                               }
                           }
                       } label: {
                           Text("Update Artist: \(model.originalName)")
                       }
                        
                    case .deleteSong(let model):
                        Text("Delete Song: \(model)")
                    case .deleteAlbum(let model):
                        Text("Delete Album: \(model)")
                    case .deleteArtist(let model):
                        Text("Delete Artist: \(model)")
                    }
                }
            }
        }
    }
}

//#Preview {
//    TransactionAssertionsScreen()
//}
