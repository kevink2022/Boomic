//
//  File.swift
//  
//
//  Created by Kevin Kelly on 4/11/24.
//

import SwiftUI
import Models

#if canImport(UIKit)
public typealias PlatformImage = UIImage
#elseif canImport(AppKit)
public typealias PlatformImage = NSImage
#endif

public protocol MediaArtLoader {
    func load(_ art: MediaArt) async -> Image
    func loadPlatformImage(for art: MediaArt) async -> PlatformImage?
}

public final class MediaArtCache : MediaArtLoader {
    
    private let cache: NSCache<NSString, ImageObject>
    private let defaultImage = Image("boomic_logo")
    
    public init(cacheLimit: Int? = nil) {
        let cache = NSCache<NSString, ImageObject>()
        if let cacheLimit = cacheLimit { cache.countLimit = cacheLimit }
        self.cache = cache
    }
    
    public func load(_ art: MediaArt) async -> Image {
        let hashKey = hashKey(for: art)
        
        if let imageObject = cache.object(forKey: hashKey as NSString) {
            return imageObject.getImage() ?? defaultImage
        }
        
        else if let newImageObject = imageObject(for: art) {
            cache.setObject(newImageObject, forKey: hashKey as NSString)
            return newImageObject.getImage() ?? defaultImage
        }
        
        else { return defaultImage }
    }
    
    public func loadPlatformImage(for art: MediaArt) async -> PlatformImage? {
        let hashKey = hashKey(for: art)
        
        if let imageObject = cache.object(forKey: hashKey as NSString) {
            return imageObject.image
        }
        
        else if let newImageObject = imageObject(for: art) {
            cache.setObject(newImageObject, forKey: hashKey as NSString)
            return newImageObject.image
        }
        
        else { return nil }
    }

    private func hashKey(for art: MediaArt) -> String {
        switch art {
        case .embedded(_, let hash): return hash
        case .local(let url): return url.path()
        }
    }
    
    private func imageObject(for art: MediaArt) -> ImageObject? {
        switch art {
        case .embedded(let url, _):
            guard let data = AudioToolboxParser.embeddedArtData(from: url) else { return nil }
            return ImageObject(data: data)
            
        case .local(let url): return ImageObject(url: url)
        }
    }
}

private final class ImageObject {
    
#if canImport(UIKit)
    public var image: UIImage?
    
    init(url: URL) {
        if let data = try? Data(contentsOf: url), let loadedImage = UIImage(data: data) {
             self.image = loadedImage
        }
    }
    
    init(data: Data) { self.image = UIImage(data: data) }
    
    public func getImage() -> Image? {
        if let image = image {
            return Image(uiImage: image)
        } else {
            return nil
        }
    }
#elseif canImport(AppKit)
    public var image: NSImage?
    
    init(url: URL) {
        self.image = NSImage(contentsOf: url)
    }
    
    init(data: Data) { self.image = NSImage(data: data) }
    
    public func getImage() -> Image? {
        if let image = image {
            return Image(nsImage: image)
        } else {
            return nil
        }
    }
#endif
}
