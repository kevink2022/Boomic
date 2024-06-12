//
//  GridListEntry.swift
//  Boomic
//
//  Created by Kevin Kelly on 6/10/24.
//

import SwiftUI

struct GridListEntry<Icon: View, Menu: View>: Identifiable {
    let id = UUID()
    let label: String
    let subLabel: String?
    let listHeader: String?
    let listFooter: String?
    let iconClip: GridListIconClip
    let action: () -> ()
    let icon: () -> Icon
    let menu: () -> Menu
    
    init(
        label: String
        , subLabel: String? = nil
        , listHeader: String? = nil
        , listFooter: String? = nil
        , iconClip: GridListIconClip = .nothing
        , action: (() -> ())?
        , @ViewBuilder icon: @escaping () -> Icon
        , @ViewBuilder menu: @escaping () -> Menu = { EmptyView() }
    ) {
        self.label = label
        self.subLabel = subLabel
        self.listHeader = listHeader
        self.listFooter = listFooter
        self.iconClip = iconClip
        self.action = action ?? {}
        self.icon = icon
        self.menu = menu
    }
}

enum GridListIconClip {
    case nothing, rounded, circle
}
