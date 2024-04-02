//
//  File.swift
//  
//
//  Created by Kevin Kelly on 3/22/24.
//

import Foundation
import AudioToolbox

public final class AudioToolboxParser {
    
    public let source: URL
    public let hasTags: Bool
    public let hasEmbeddedArt: Bool
    private let tags: [String : Any]?
    private typealias S = AudioToolboxParser
    
    init(file: URL) {
        source = file
        
        guard let fileID = S.openFile(url: file) else {
            hasTags = false
            hasEmbeddedArt = false
            tags = nil
            return
        }
        defer { S.closeFile(fileID) }
        
        tags = S.initTags(fileID)
        hasTags = tags == nil ? false : true
        hasEmbeddedArt = S.hasEmbedded(fileID)
    }
    
    private static func openFile(url: URL) -> AudioFileID? {
        guard let fileType = S.fileToType(url) else { return nil }
        
        var fileID: AudioFileID? = nil
        let fileOpenStatus: OSStatus = AudioFileOpenURL(url as CFURL, .readPermission, fileType, &fileID)
        guard fileOpenStatus == noErr else { return nil }
        return fileID
    }
    
    private static func closeFile(_ fileID: AudioFileID) {
        AudioFileClose(fileID)
    }
    
    private static func initTags(_ fileID: AudioFileID) -> [String : Any]? {
        var dict: CFDictionary? = nil
        var dataSize = UInt32(MemoryLayout<CFDictionary?>.size(ofValue: dict))
        
        let getPropertyStatus: OSStatus = AudioFileGetProperty(fileID, kAudioFilePropertyInfoDictionary, &dataSize, &dict)
        guard getPropertyStatus == noErr else { return nil }
        
        guard let cfDict = dict else { return nil }
        let tagsDict = NSDictionary.init(dictionary: cfDict)
        return tagsDict as? [String : Any]
    }
    
    private static func hasEmbedded(_ fileID: AudioFileID) -> Bool {
        var dataSize: UInt32 = 0
        let status = AudioFileGetPropertyInfo(fileID, kAudioFilePropertyAlbumArtwork, &dataSize, nil)

        guard status == noErr && dataSize > 0 else { return false }
            
        var artworkData: UnsafeMutableRawPointer? = nil
        let result = AudioFileGetProperty(fileID, kAudioFilePropertyAlbumArtwork, &dataSize, &artworkData)
        
        guard result == noErr && artworkData != nil else { return false }
            
        return true
    }
    
    private static func embeddedArt(_ fileID: AudioFileID) -> Data? {
        var dataSize: UInt32 = 0
        let status = AudioFileGetPropertyInfo(fileID, kAudioFilePropertyAlbumArtwork, &dataSize, nil)

        guard status == noErr && dataSize > 0 else { return nil }
            
        var artworkData: UnsafeMutableRawPointer? = nil
        let result = AudioFileGetProperty(fileID, kAudioFilePropertyAlbumArtwork, &dataSize, &artworkData)
        
        guard result == noErr, let artworkDataUnwrapped = artworkData else { return nil }
            
        let dataRef = Unmanaged<CFData>.fromOpaque(artworkDataUnwrapped).takeRetainedValue()
        let data = Data(referencing: dataRef)
        
        return data
    }
    
    private static func fileToType(_ file: URL) -> AudioFileTypeID? {
        switch file.pathExtension.lowercased() {
        case "mp3": return kAudioFileMP3Type
        case "flac": return kAudioFileFLACType
        case "m4a": return kAudioFileM4AType
        default: return nil
        }
    }
    
    private func parseTrackNumber(_ trackNumberString: String?) -> Int? {
        guard let trackNumberString = trackNumberString else { return nil }
        return Int(trackNumberString.split(separator: "/")[0])
    }
    
    public var allTags: [String : Any]? { tags }
    
    public var title: String? { tags?["title"] as? String }
    public var artist: String? { tags?["artist"] as? String }
    public var album: String? { tags?["album"] as? String }
    public var genre: String? { tags?["genre"] as? String }
    
    public var year: Int? { tags?["year"] as? Int ?? tags?["recorded date"] as? Int }
    public var date: Date? { tags?["recorded date"] as? Date }
    
    public var duration: TimeInterval? { TimeInterval(tags?["approximate duration in seconds"] as? String ?? "") }
    public var trackNumber: Int? { parseTrackNumber(tags?["track number"] as? String) }

    public var comments: String? { tags?["comments"] as? String }
    
    public static func embeddedArtData(from url: URL) -> Data? {
        guard let fileID = S.openFile(url: url) else { return nil }
        defer { S.closeFile(fileID) }
        return S.embeddedArt(fileID)
    }
}
