//
//  TagViewsScreen.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/21/24.
//

import SwiftUI

private typealias F = ViewConstants.Fonts
private typealias SI = ViewConstants.SystemImages

struct TagViewsScreen: View {
    @Environment(\.navigator) private var navigator
    @Environment(\.repository) private var repository
    
    var body: some View {
        List {
            Section {
                HStack(spacing: 0) {
                    Text("Current TagView: ")
                    Text(repository.activeTagView?.label ?? "Global")
                        .font(F.bold)
                }
            }

            Section {
                Button {
                    repository.resetToGlobalTagView()
                } label: {
                    HStack {
                        Image(systemName: SI.link)
                        Text("Reset to Global")
                    }
                }
                .disabled(repository.activeTagView == nil)
            }
            
            Section {
                ForEach(repository.tagViews.values) { list in
                    Button {
                        Task { await repository.setActiveTagView(to: list) }
                    } label: {
                        Text(list.label)
                    }
                    .contextMenu {
                        Button {
                            navigator.settings.navigateTo(list)
                        } label: {
                            HStack {
                                Label("Edit", systemImage: SI.edit)
                            }
                        }
                    }
                }
                
                NavigationLink(value: SettingsNavigation.newTagView) {
                    HStack {
                        Image(systemName: SI.add)
                        Text("Add New View")
                    }
                }
            }
        }
    }
}

#Preview {
    TagViewsScreen()
}
