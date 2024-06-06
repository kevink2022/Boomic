//
//  GridListConfiguration.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/5/24.
//

import SwiftUI

struct GridListConfiguration: Identifiable {
    public let key: String
    public var id: String { key }
    public var showLabels: Bool
    public private(set) var columnCount: Int
    
    
    static let standard = GridListConfiguration(
        key: "standard"
    )
    
    init(
        key: String
        , columnCount: Int = 3
        , showLabels: Bool = true
    ) {
        self.key = key
        self.showLabels = showLabels
        self.columnCount = columnCount
    }
    
    public var gridMode: Bool { columnCount <= Self.maxColumns }
    public var listMode: Bool { !gridMode }
    public var largeList: Bool { columnCount == Self.largeListCount }
    public var mediumList: Bool { columnCount == Self.mediumListCount }
    public var smallList: Bool { columnCount == Self.smallListCount }
    
    private static let minColumns = 2
    private static let maxColumns = 5
    private static let maxInternalColumns = Self.smallListCount
    static let largeListCount = Self.maxColumns + 1
    static let mediumListCount = Self.maxColumns + 2
    static let smallListCount = Self.maxColumns + 3
    
    static let oneColumn: [GridItem] = Array(repeating: .init(.flexible()), count: 1)
    var columns: [GridItem] { Array(repeating: .init(.flexible()), count: columnCount) }
    
    var canZoomIn: Bool { columns.count > Self.minColumns }
    var canZoomOut: Bool { columns.count < Self.maxInternalColumns }
    
    mutating func zoomIn() {
        if canZoomIn {
            columnCount -= 1
        }
    }
    
    mutating func zoomOut() {
        if canZoomOut {
            columnCount += 1
        }
    }
}

extension GridListConfiguration: Equatable {
    static func == (lhs: GridListConfiguration, rhs: GridListConfiguration) -> Bool {
        lhs.key == rhs.key
        && lhs.showLabels == rhs.showLabels
        && lhs.columnCount == rhs.columnCount
    }
}

extension GridListConfiguration: Codable {
    enum CodingKeys: String, CodingKey {
        case key
        case showLabels
        case columnCount
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(key, forKey: .key)
        try container.encode(showLabels, forKey: .showLabels)
        try container.encode(columnCount, forKey: .columnCount)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        key = try container.decode(String.self, forKey: .key)
        showLabels = try container.decode(Bool.self, forKey: .showLabels)
        columnCount = try container.decode(Int.self, forKey: .columnCount)
    }
}
