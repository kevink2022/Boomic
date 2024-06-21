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
                    switch assertion.code {
                    case .addSong(let model):
                        NavigationLink {
                            SongAddDetailsScreen(model: model, timestamp: transaction.timestamp)
                        } label: {
                            Text("Add Song: \(model.label)")
                        }
                        
                    case .addAlbum(let model):
                        NavigationLink {
                            AlbumAddDetailsScreen(model: model, timestamp: transaction.timestamp)
                        } label: {
                            Text("Add Album: \(model.title)")
                        }
                        
                    case .addArtist(let model):
                        NavigationLink {
                            ArtistAddDetailsScreen(model: model, timestamp: transaction.timestamp)
                        } label: {
                            Text("Add Artist: \(model.name)")
                        }
                    case .updateSong(let model):
                        NavigationLink {
                            SongUpdateDetailsScreen(model: model, timestamp: transaction.timestamp)
                        } label: {
                            Text("Update Song: \(model.label)")
                        }
                        
                    case .updateAlbum(let model):
                        NavigationLink {
                            AlbumUpdateDetailsScreen(model: model, timestamp: transaction.timestamp)
                        } label: {
                            Text("Update Album: \(model.originalTitle)")
                        }
                        
                    case .updateArtist(let model):
                        NavigationLink {
                            ArtistUpdateDetailsScreen(model: model, timestamp: transaction.timestamp)
                        } label: {
                            Text("Update Artist: \(model.originalName)")
                        }
                        
                    case .delete(let model):
                        NavigationLink {
                            DeleteAssertionDetailsScreen(model: model, timestamp: transaction.timestamp)
                        } label: {
                            Text("Delete \(model.model.label): \(model.label)")
                        }
                        
                    default: Text("fixme")
                    }
                }
            }
        }
    }
}

//#Preview {
//    TransactionAssertionsScreen()
//}
