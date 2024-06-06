//
//  TransactionDetailsScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 4/28/24.
//

import SwiftUI
import Database

private typealias C = ViewConstants
private typealias F = ViewConstants.Fonts

struct TransactionDetailsScreen: View {
    let transaction: DataTransaction<KeySet<LibraryTransaction>>
    var body: some View {
        Text("TransactionDetailsScreen")
        
         VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading) {
//                Text(transaction.body.decode)
//                    .font(F.sectionTitle)
                Text(transaction.timestamp.shortFormatted)
                    .font(F.body)
            }
            .padding(20)
             
             List {
                 ForEach(transaction.data.values) { transaction in
                     switch transaction {
                     case .addSong(let model):
                         Text("Add Song: \(model.label)")
                     case .addAlbum(let model):
                         Text("Add Album: \(model.title)")
                     case .addArtist(let model):
                         Text("Add Artist: \(model.name)")
                     case .updateSong(let model):
                         Text("Update Song:\(model.label)")
                     case .updateAlbum(let model):
                         Text("Update Album: \(model.newTitle ?? model.originalTitle)")
                     case .updateArtist(let model):
                         Text("Update Artist: \(model.newName ?? model.originalName)")
                     case .deleteSong(let model):
                         Text("Delete Song:\(model)")
                     case .deleteAlbum(let model):
                         Text("Delete Album: \(model)")
                     case .deleteArtist(let model):
                         Text("Delete Artist: \(model)")
                     }
                 }
             }
            
             
            /*switch transaction.data {
            case .addSongs(let songs):
                List{ ForEach(songs){ song in
                    Text(song.source.label)
                }}
            case .updateSong(let update):
                Text("Update to \(update.label)")
                
                List{
                    if let value = update.title { Text("Title: \(value)") }
                    if let value = update.trackNumber { Text("Track Number: \(value)") }
                    if let value = update.discNumber { Text("Disc Number: \(value)") }
                    if let value = update.artists { Text("Artists: \(value)") }
                    if let value = update.albums { Text("Albums: \(value)") }
                    if let value = update.artistName { Text("Artist Name: \(value)") }
                    if let value = update.albumTitle { Text("Album Title: \(value)") }
                    if let value = update.art { Text("Art: \(value)") }
                    if let value = update.rating { Text("Rating: \(value)") }
                    
                    if let keysErased = update.erasing {
                        ForEach(Array(keysErased), id: \.self) { key in
                            Text("Erased \(key)")
                        }
                    }
                }
            }*/
        }
    }
}

//#Preview {
//    TransactionDetailsScreen()
//}
