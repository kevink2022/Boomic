//
//  TimeInterval.swift
//  Boomic
//
//  Created by Kevin Kelly on 3/17/24.
//

import Foundation

extension TimeInterval {
    var formatted: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .dropLeading
        
        return formatter.string(from: self) ?? "0:00"
    }
}
