//
//  File.swift
//  
//
//  Created by Kevin Kelly on 5/16/24.
//

import Foundation

public class FileInterface {
    
    private let root: URL
    private let fileManager: FileManager
    
    public init (
        at root: URL
        , fileManager: FileManager = FileManager()
    ) {
        self.root = root
        self.fileManager = fileManager
    }
    
    public func allFiles(of extensions: Set<String>? = nil, excluding: Set<URL>? = nil) throws -> [URL] {
        guard let enumerator = fileManager.enumerator(at: root, includingPropertiesForKeys: [.isHiddenKey])
        else { throw MediaFileInterfaceError.enumeratorInitFail(root) }
        
        let allURLs = enumerator.allObjects.compactMap { $0 as? URL }
        
        let allExtensionURLs = allURLs.filter { extensions?.contains($0.pathExtension.lowercased()) ?? true
        }
        
        let allNewURLs = {
            if let excluding = excluding, excluding.count > 1 {
                return allExtensionURLs.filter{ !excluding.contains($0) }
            } else {
                return allExtensionURLs
            }
        }()
        
        return allNewURLs
    }
}
