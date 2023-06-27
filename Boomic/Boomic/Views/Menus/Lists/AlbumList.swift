//
//  AlbumList.swift
//  Boomic
//
//  Created by Kevin Kelly on 11/14/22.
//

import SwiftUI

struct AlbumList: View
{
    @EnvironmentObject var manager : BoomicManager
    let albums : [Album]
    
    var body: some View
    {
        VStack
        {
            GridMenu
            {
                ForEach(albums)
                {
                    album in
                    
                    NavigationLink
                    {
                        AlbumPage(album: album)
                    }
                    label:
                    {
                        AlbumEntry(album: album)
                    }
                }
            }
        }
    }
}

//struct AlbumList_Previews: PreviewProvider {
//    static var previews: some View {
//        AlbumList()
//            .environmentObject(BoomicManager())
//    }
//}
