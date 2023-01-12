//
//  BoomicError.swift
//  Boomic
//
//  Created by Kevin Kelly on 12/8/22.
//

import Foundation

enum BoomicError : Error
{
    case genericError
    case pcmBufferNil
    
    var localizedDescription: String
    {
        switch self
        {
        case .genericError:
            return "I haven't decided how to properly organize my errors yet"
        case .pcmBufferNil:
            return "The PCM buffer returned nil"
        }
    }
}
