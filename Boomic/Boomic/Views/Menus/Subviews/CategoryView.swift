//
//  CategoryView.swift
//  Boomic
//
//  Created by Kevin Kelly on 11/14/22.
//

import SwiftUI

struct CategoryView: View
{
    let category : Category
    
    var body: some View
    {
        ZStack
        {
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 5)
                .foregroundColor(.primary)
            
            VStack
            {
                Image(category.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                Text(category.label)
                    .font(C.labelFont)
            }
            .foregroundColor(.primary)
            .padding()
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    typealias C = VC
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
//        CategoryView(image: .systemName("music.note"), label: "Songs")
//        CategoryView(image: .systemName("music.note.list"), label: "Playlists")
        CategoryView(category: Category.songs)
    }
}

struct VC
{
    static let imageFont = Font.system(.largeTitle, design: .default, weight: .heavy)
    static let labelFont = Font.system(.title, design: .rounded, weight: .bold)
}
