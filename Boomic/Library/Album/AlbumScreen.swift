//
//  AlbumScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/16/24.
//

import SwiftUI
import Models
import Database
import DatabaseMocks
import ModelsMocks

struct AlbumScreen: View {
    @Environment(\.database) private var database
    let album: Album
    @State private var songs: [Song] = []
    
    var body: some View {
        List {
            VStack {
                HStack {
                    Spacer(minLength: 70)
                    
                    Image("boomic_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerSize: CGSize(
                            width: C.albumCornerRadius,
                            height: C.albumCornerRadius
                        )))
                    
                    Spacer(minLength: 70)
                }
                
                Text(album.title)
                    .font(F.title)
                    .lineLimit(1)
                
                Text(album.artistName ?? "Unknown Artist")
                    .font(F.subtitle)
                    .lineLimit(1)
                
                HStack {
                    Text("Songs")
                        .font(F.title)
                    
                    Spacer()
                }
                
            }
            
            
            
            SongList(songs: songs)
            
        }
        .listStyle(.inset)
        .task {
            songs = await database.getSongs(for: album.songs)
        }
    }
    
    typealias C = ViewConstants
    typealias F = ViewConstants.Fonts
}

#Preview {
    AlbumScreen(album: Album.girlsApartment)
        .environment(\.database, GirlsApartmentDatabase())
}
