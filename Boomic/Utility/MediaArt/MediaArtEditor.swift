//
//  MediaArtEditor.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/21/24.
//

import SwiftUI
import Domain
import Models
import MediaFileKit

private typealias SI = ViewConstants.SystemImages

struct MediaArtEditor: View {
    @Binding private var art: MediaArt?
    private let originalArt: MediaArt?
    private let editing: Bool
    private let aspectRatio: ContentMode
    private let cornerRadius: CGFloat
    
    @State var showingFilePicker = false
    
    init(
        _ art: Binding<MediaArt?>
        , editing: Bool = false
        , aspectRatio: ContentMode = .fit
        , cornerRadius: CGFloat = 0
    ) {
        self._art = art
        self.originalArt = art.wrappedValue
        self.editing = editing
        self.aspectRatio = aspectRatio
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        Menu {
            Section("Choose new Photo") {
                Button {
                    
                } label: {
                    Label("From Photo Library", systemImage: SI.photos)
                }
                Button {
                    
                } label: {
                    Label("From Files", systemImage: SI.documents)
                }
                .fileImporter(isPresented: $showingFilePicker, allowedContentTypes: [.image]) { handleFile($0) }
                
                Button {
                    
                } label: {
                    Label("From Online", systemImage: SI.link)
                }
                
                if art != originalArt {
                    Button {
                        art = originalArt
                    } label: {
                        Label("Reset to original", systemImage: SI.undo)
                    }
                }
            }
            
        } label: {
            ZStack {
                if editing {
                    Rectangle()
                        .opacity(0.6)
                        .aspectRatio(1.0, contentMode: aspectRatio)
                        .cornerRadius(cornerRadius)
                }
                
                MediaArtView(art, aspectRatio: aspectRatio, cornerRadius: cornerRadius)
                    .padding(editing ? 15 : 0)
            }
        }
        .disabled(!editing)
//        .foregroundStyle(.primary)
    }
    
    private func handleFile(_ result:  Result<URL, any Error>) {
        switch result {
        case .success(let url):
            let appPath = AppPath(url: url)
            art = MediaArt.local(path: appPath)
        case .failure(let error):
            print("File import failed: \(error.localizedDescription)")
        }
    }
}

#Preview {
    MediaArtEditor(.constant(.test), editing: true, cornerRadius: 10)
        .environment(\.repository, PreviewMocks.shared.previewRepository())
}

