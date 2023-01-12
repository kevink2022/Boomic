//
//  ContainerProtocol.swift
//  Boomic
//
//  Created by Kevin Kelly on 11/14/22.
//

import SwiftUI

// Source: https://www.swiftbysundell.com/tips/creating-custom-swiftui-container-views/
protocol ContainerView: View
{
    associatedtype Content
    
    init(content: @escaping () -> Content)
}

extension ContainerView
{
    init(@ViewBuilder _ content: @escaping () -> Content)
    {
        self.init(content: content)
    }
}
