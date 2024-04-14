//
//  File.swift
//  
//
//  Created by Kevin Kelly on 4/13/24.
//

import Foundation
import CryptoKit

internal final class HashUtility {
    internal static func computeHash(data: Data) -> String {
        let hash = Insecure.MD5.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
