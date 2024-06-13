//
//  ArtistScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/17/24.
//

import SwiftUI
import Models

private typealias C = ViewConstants
private typealias F = ViewConstants.Fonts
private typealias A = ViewConstants.Animations

struct ArtistScreen: View {
    @Environment(\.navigator) private var navigator
    @Environment(\.repository) private var repository
    @Environment(\.preferences) private var preferences
    @Environment(\.selector) private var selector
    
    let baseArtist: Artist
    private var artist: Artist { repository.artist(baseArtist) ?? baseArtist }
    private var songs: [Song] { repository.songs(artist.songs) }
    private var albums: [Album] { repository.albums(artist.albums) }
    private var exists: Bool { repository.artist(baseArtist) != nil }
    
    init(artist: Artist) {
        self.baseArtist = artist
    }
    
    private let topSongCount = 3
    @State private var showAllSongs = false
    
    @State private var predicate: String = ""
    private var primaryOnly: Bool { preferences.localSearchOnlyPrimary }

    var body: some View {
        @Bindable var nav = navigator
        
        ScrollView {
            LazyVStack {
                if !nav.isSearchFocused {
                    VStack {
                        MediaArtView(artist.art)
                            .clipShape(Circle())
                            .padding(.horizontal, C.artistScreenHeaderPadding)
                        
                        Text(artist.name)
                            .font(F.title)
                            .multilineTextAlignment(.center)
                        
                        Text("\(albums.count) albums • \(songs.count) tracks")
                            .font(F.listDuration)
                    }
                    .padding(C.gridPadding)
                }
                
                SongGrid(
                    songs: Array(songs.search(predicate, primaryOnly: primaryOnly).prefix((showAllSongs || nav.isSearchFocused) ? songs.count : topSongCount))
                    , key: nil
                    , config: .smallIconList
                    , header: .buttonsHidden
                    , selectable: selector.group == .songs
                    , title: "Songs"
                    , titleFont: F.sectionTitle
                    , queueName: artist.name
                    , showTrackNumber: false
                )

                if !nav.isSearchFocused && topSongCount < songs.count {
                    Button {
                        withAnimation(A.artistScreenShowAllSongs) { showAllSongs.toggle() }
                    } label: {
                        ZStack {
                            Color(.clear)
                            Text(showAllSongs ? "Show Less" : "Show All")
                        }
                        .frame(height: C.smallAlbumFrame - 5)
                    }
                    
                    Divider()
                }
                
                AlbumGrid(
                    albums: albums.search(predicate, primaryOnly: primaryOnly)
                    , key: Preferences.GridKeys.artistAlbums
                    , header: .standard
                    , selectable: selector.group == .artists
                    , title: "Albums"
                    , titleFont: F.sectionTitle
                )
                .padding(.top)
            }
        }
        
        .searchable(text: $predicate, isPresented: $nav.isSearchFocused)
        
        .onChange(of: exists) { oldValue, newValue in
            if newValue == false { navigator.library.navigateBack() }
        }
    }
}

#Preview {
    ArtistScreen(artist: PreviewMocks.shared.previewArtist())
        .environment(\.repository, PreviewMocks.shared.previewRepository())
}
