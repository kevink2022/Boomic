//
//  MediaCollection.swift
//  Boomic
//
//  Created by Kevin Kelly on 1/15/24.
//

import Foundation
import Models

public protocol MediaCollection: MediaCollectionItem {
    var items: [any MediaCollectionItem] { get }
}

public protocol MediaCollectionItem : Identifiable {
    var id: UUID { get }
    var label: String { get }
    var subLabel: String? { get }
    var art: MediaArt? { get }
    var duration: TimeInterval { get }
}

// MARK: - Song Conformance

extension Song: MediaCollectionItem {
    public var label: String { title ?? source.label }
    public var subLabel: String? { artist?.label }
}

// MARK: - Album Conformance

extension Album: MediaCollection {
    public var items: [any MediaCollectionItem] { [] }
}

extension Album: MediaCollectionItem {
    public var duration: TimeInterval { 0 }
    public var label: String { title }
    public var subLabel: String? { artist?.label }
}

// MARK: - Artist Conformance

extension Artist: MediaCollection {
    public var items: [any MediaCollectionItem] { albums }
}

extension Artist: MediaCollectionItem {
    public var duration: TimeInterval { 0 }
    
    public var label: String { name }
    public var subLabel: String? { nil }
    public var art: MediaArt? { nil }
}
