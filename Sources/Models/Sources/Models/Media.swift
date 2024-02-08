//
//  File.swift
//  
//
//  Created by Kevin Kelly on 2/7/24.
//

import Foundation

public protocol Media {
    var source : MediaSource { get }
}

public enum MediaSource {
    case local(URL)
}

public enum MediaArt {
    case local(URL)
    case embedded(URL)
}

extension MediaSource {
    public var label : String {
        switch self {
        case .local(let url): return url.lastPathComponent
        }
    }
}
