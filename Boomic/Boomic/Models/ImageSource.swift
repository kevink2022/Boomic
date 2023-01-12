//
//  ImageSource.swift
//  Boomic
//
//  Created by Kevin Kelly on 11/14/22.
//

import Foundation
import SwiftUI

/// Views with images being passed to them will use image source to determine how to process the image
enum ImageSource : Codable
{
    case systemName(String)
    case asset(String)
    case url(URL)
    case data(Data)
}

extension Image
{
    init(_ source : ImageSource)
    {
        switch source
        {
        case .systemName(let image):
            self.init(systemName: image)
        
        case .asset(let image):
            self.init(image)
            
        case .data(let data):
            if let uiImage = UIImage(data: data)
            {
                self.init(uiImage: uiImage)
            }
            else
            {
                self.init(systemName: "exclamationmark.triangle.fill")
            }
        
        // TODO: I really don't like this
        // TODO: Add remote URL support
        case .url(let source):
            
            if let data = try? Data(contentsOf: source)
            {
                if let uiImage = UIImage(data: data)
                {
                    self.init(uiImage: uiImage)
                    break
                }
            }
            self.init(systemName: "exclamationmark.triangle.fill")
        }
    }
}
