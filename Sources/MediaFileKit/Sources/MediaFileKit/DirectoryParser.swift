//
//  File.swift
//  
//
//  Created by Kevin Kelly on 3/23/24.
//

import Foundation

public final class DirectoryParser {
    
    let source: URL
    private let fileManager: FileManager
    
    public private(set) var externalAlbumArt: URL?

    private typealias S = DirectoryParser
    
    init(
        file: URL
        , fileManager: FileManager = FileManager()
    ) {
        self.source = file
        self.fileManager = fileManager
    }
    
    private func extractDiscNumber(from fileURL: URL) -> Int? {
        let pathComponents = fileURL.pathComponents
        guard pathComponents.count >= 2 else { return nil }
        
        let directoryName = pathComponents[pathComponents.count - 2]
        
        let regex = try! NSRegularExpression(pattern: S.discRegex, options: .caseInsensitive)
        let nsString = directoryName as NSString
        let results = regex.matches(in: directoryName, options: [], range: NSRange(location: 0, length: nsString.length))
        
        if let match = results.first, let range = Range(match.range(at: 1), in: directoryName) {
            return Int(directoryName[range])
        }
        
        return nil
    }
    
    func albumArtInDirectory(_ directoryURL: URL) -> URL? {
        let filesInDirectory: [URL]
        
        do {
            filesInDirectory = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: [])
        } catch {
            print("Error reading directory contents: \(error)")
            return nil
        }

        let artworkFiles = filesInDirectory.filter { url in
            let fileName = url.deletingPathExtension().lastPathComponent.lowercased()
            let fileExtension = url.pathExtension.lowercased()
            return S.albumArtNames.contains(fileName) && S.albumArtExtensions.contains(fileExtension)
        }
        
        return artworkFiles.first
    }
    
    public var allTags: [String : Any]? { [:] }
    
    public var discNumber: Int? { extractDiscNumber(from: source) }
    
    public var albumArt: URL? {
        let songDir = source.deletingLastPathComponent()
        if let art = albumArtInDirectory(songDir) { return art }
        
        guard let _ = extractDiscNumber(from: source) else { return nil }
        
        let rootDir = songDir.deletingLastPathComponent()
        if let art = albumArtInDirectory(rootDir) { return art }
        
        if let art = try? fileManager
            .contentsOfDirectory(at: rootDir, includingPropertiesForKeys: [.isDirectoryKey], options: .skipsHiddenFiles)
            .filter({ $0 != songDir })
            .compactMap({ albumArtInDirectory($0) })
            .first
        { return art }
        
        return nil
    }
    
    private static let discRegex = "Disc\\s+(\\d+)"
    private static let albumArtNames = ["cover", "folder", "album"]
    private static let albumArtExtensions = ["jpg", "png"]
}
