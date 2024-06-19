//
//  GridListSelectorBar.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/12/24.
//

import SwiftUI

private typealias C = ViewConstants
private typealias F = ViewConstants.Fonts
private typealias A = ViewConstants.Animations
private typealias SI = ViewConstants.SystemImages

struct GridListSelectorBar: View {
    @Environment(\.navigator) private var navigator
    @Environment(\.preferences) private var preferences
    @Environment(\.repository) private var repository
    @Environment(\.selector) private var selector
    
    let selectable: Bool
    let localIDs: [UUID]
    let externalHorizontalPadding: CGFloat
    
    private var count: Int { selector.selected.count }
    private var show: Bool { selectable && selector.active }
    private var allSelected: Bool { 
        nil == localIDs.first(where: { !selector.isSelected($0) })
    }
    
    private var model: String {
        switch selector.group {
        case .songs: "Song"
        case .albums: "Album"
        case .artists: "Artist"
        default: ""
        }
    }
    
    var body: some View {
        if !show { EmptyView() }
        
        else {
            ZStack {
                Color(UIColor.systemBackground)
                
                VStack(spacing: 0) {
                    Divider()
                    
                    HStack {
                        Menu {
                            if allSelected {
                                Button {
                                    localIDs.forEach { selector.deselect($0) }
                                } label: {
                                    Label("Deselect All", systemImage: SI.unselected)
                                }
                            } else {
                                Button {
                                    localIDs.forEach { selector.select($0) }
                                } label: {
                                    Label("Select All", systemImage: SI.select)
                                }
                            }
                            
                            Button {
                                navigator.presentSheet(ShowAllSelections())
                            } label: {
                                Label("View All Selections", systemImage: SI.viewSelections)
                            }
                        } label: {
                            Image(systemName: SI.information)
                                .font(F.playerButton)
                        }
                        
                        Text(model + "s" + ": \(count)")
                            .font(F.listEntryTitle)
                            .opacity(0.5)
                        
                        Spacer()
                        
                        Button {
                            
                        } label: {
                            Image(systemName: SI.add)
                                .font(F.playerButton)
                        }
                        .disabled(selector.noSelections)
                        
                        Menu {
                            Button {
                                editSelections()
                            } label: {
                                Label("Edit Selections", systemImage: SI.edit)
                            }
                            
                            Button(role: .destructive) {
                                deleteSelections()
                            } label: {
                                Label("Delete Selections", systemImage: SI.delete)
                            }
                            
                        } label: {
                            Image(systemName: SI.editSelections)
                                .font(F.playerButton)
                        }
                        .disabled(selector.noSelections)
                        
                        AnimatedButton(A.artistScreenShowAllSongs) {
                            selector.cancel()
                        } label: {
                            Image(systemName: SI.cancelSelection)
                                .font(F.playerButton)
                        }
                    }
                    .padding(C.gridPadding)
                    
                    Divider()
                }
            }
            .padding(.horizontal, -externalHorizontalPadding)
        }
    }
    
    private func editSelections() {
        switch selector.group {
        case nil: break
            
        case .songs:
            let songs = repository.songs(Array(selector.selected))
            navigator.presentSheet(SongUpdateSheet(songs: Set(songs)))
            break
            
        case .albums:
            let albums = repository.albums(Array(selector.selected))
            navigator.presentSheet(AlbumUpdateSheet(albums: Set(albums)))
            
        case .artists:
            let artists = repository.artists(Array(selector.selected))
            navigator.presentSheet(ArtistUpdateSheet(artists: Set(artists)))
        }
    }
    
    private func deleteSelections() {
        switch selector.group {
        case nil: break
            
        case .songs:
            Task {
                let songs = repository.songs(Array(selector.selected))
                await repository.deleteSongs(Set(songs))
                selector.cancel()
            }
            break
            
        case .albums:
            Task {
                let albums = repository.albums(Array(selector.selected))
                await repository.deleteAlbums(Set(albums))
                selector.cancel()
            }
            break
            
        case .artists:
            Task {
                let artists = repository.artists(Array(selector.selected))
                await repository.deleteArtists(Set(artists))
                selector.cancel()
            }
            break
        }
    }
}

#Preview {
    GridListSelectorBar(selectable: true, localIDs: [], externalHorizontalPadding: 0)
}
