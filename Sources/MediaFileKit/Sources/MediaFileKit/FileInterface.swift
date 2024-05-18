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
        
        return enumerator.allObjects
            .compactMap { $0 as? URL }
            .filter { !(excluding?.contains($0) ?? false) }
            .filter { extensions?.contains($0.pathExtension.lowercased()) ?? true }
    }
}
