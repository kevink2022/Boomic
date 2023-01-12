//
//  GridMenu.swift
//  Boomic
//
//  Created by Kevin Kelly on 11/14/22.
//

import SwiftUI

struct GridMenu<Content: View> : ContainerView
{
    var content : () -> Content
    
    var body: some View
    {
        GeometryReader
        {
            geo in
            
            ScrollView
            {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: geo.size.width/3), spacing: 8)])
                {
                    content()
                }
                .padding()
            }
        }
    }
}


struct GridMenu_Previews: PreviewProvider {
    static var previews: some View {
        GridMenu
        {
            ScrollView
            {
                Image(systemName: "signature")
                Image(systemName: "signature")
                Image(systemName: "signature")
                Image(systemName: "signature")
            }
        }
    }
}
