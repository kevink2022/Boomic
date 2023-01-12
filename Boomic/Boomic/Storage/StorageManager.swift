//
//  StorageManager.swift
//  US States
//
//  Created by Hannan, John Joseph on 10/17/22.
//  Modified by Kevin Kelly
//
import Foundation

class StorageManager<SomeData:Codable>
{
    let modelData : SomeData?
    private var fileInfo : FileInfo
    private let fileName : String
    
    init(fileName name : String)
    {
        fileName = name
        fileInfo = FileInfo(for: fileName)
        
        if fileInfo.exists
        {
            let decoder = JSONDecoder()
            
            do
            {
                let data = try Data.init(contentsOf: fileInfo.url)
                modelData = try decoder.decode(SomeData.self, from: data)
            }
            catch
            {
                print(error)
                modelData = nil
            }
            return
        }
        
        
        /// The library will be stored in the main bundle so the user doesn't acciedently delete or corrupt it.
        /// However, they should be able to export the raw json if they want.
        let mainBundle = Bundle.main
        let url = mainBundle.url(forResource: fileName, withExtension: "json")
        
        guard url != nil else
        {
            modelData = nil
            return
        }
        
        do
        {
            let data = try Data.init(contentsOf: url!)
            let decoder = JSONDecoder()
            modelData = try decoder.decode(SomeData.self, from: data)
        }
        catch
        {
            print(error)
            modelData = nil
        }
    }
    
    func save(modelData:SomeData) {

        let url = fileInfo.url
        let encoder = JSONEncoder()
        do
        {
            let data = try encoder.encode(modelData)
            try data.write(to: url)
        }
        catch
        {
                
        }
    }
}
