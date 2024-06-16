//
//  GridListEntry.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/10/24.
//

import SwiftUI

struct GridListEntry<Icon: View, Menu: View>: Identifiable {
    let id = UUID()
    let selectionID: UUID?
    let label: String
    let subLabel: String?
    let listHeader: String?
    let listFooter: String?
    let selectionGroup: SelectionGroup?
    let action: () -> ()
    let icon: () -> Icon
    let menu: () -> Menu
    
    init(
        label: String
        , subLabel: String? = nil
        , listHeader: String? = nil
        , listFooter: String? = nil
        , selectionGroup: SelectionGroup? = nil
        , selectionID: UUID? = nil
        , action: (() -> ())?
        , @ViewBuilder icon: @escaping () -> Icon
        , @ViewBuilder menu: @escaping () -> Menu = { EmptyView() }
    ) {
        self.label = label
        self.subLabel = subLabel
        self.listHeader = listHeader
        self.listFooter = listFooter
        self.selectionGroup = selectionGroup
        self.selectionID = selectionID
        self.action = action ?? {}
        self.icon = icon
        self.menu = menu
    }
}

enum GridListIconClip {
    case nothing, rounded, circle
}
