//
//  File.swift
//  
//
//  Created by Kevin Kelly on 6/23/24.
//

import Foundation
import Storage
import Database

extension Repository {
    public func getTransactions(last count: Int? = nil) async -> [DataTransaction<LibraryTransaction>] {
        return await transactor.viewTransactions(last: count)
    }
    
    public func deleteLibraryData() async {
        if let lastTransaction = await transactor.viewTransactions().last {
            await transactor.rollbackTo(before: lastTransaction)
        }
    }
    
    public func rollbackTo(after transaction: DataTransaction<LibraryTransaction>) async {
        statusKeys.insert(.rollback)
        status = RepositoryStatus(key: .importSongs, message: "Rebuilding Database")
        await transactor.rollbackTo(after: transaction)
        statusKeys.remove(.rollback)
    }
    
    public func rollbackTo(before transaction: DataTransaction<LibraryTransaction>) async {
        statusKeys.insert(.rollback)
        status = RepositoryStatus(key: .importSongs, message: "Rebuilding Database")
        await transactor.rollbackTo(before: transaction)
        statusKeys.remove(.rollback)
    }
    
    
    public func libraryFilesSizeAndAllocatedSize() async -> (String, String) {
        guard let (size, allocatedSize) = try? fileInterface.sizeAndAllocatedSize() else {
            return ("Error Retrieving Data", "Error Retrieving Data")
        }
        return (size.fileSize, allocatedSize.fileSize)
    }
    
    public func libraryDataSizeAndAllocatedSize() async -> (String, String) {
        guard let (size, allocatedSize) = try? await transactor.sizeAndAllocatedSize() else {
            return ("Error Retrieving Data", "Error Retrieving Data")
        }
        return (size.fileSize, allocatedSize.fileSize)
    }
}

extension Repository {
    private static let exportURL = URL
        .documentsDirectory
        .appending(path: "boomic_data_export/")
    
    private static let namespace = "library_data"
    
    public static let transactorKey = StorageKey(
        namespace: Repository.namespace
        , key: "library_history"
        , version: 0
    )
    
    internal static let tagViewsKey = StorageKey(
        namespace: Repository.namespace
        , key: "tagViews"
        , version: 0
    )
    
    internal static let activeTagViewKey = StorageKey(
        namespace: Repository.namespace
        , key: "activeTagView"
        , version: 0
    )
    
    public func exportTransactionHistory() async {
        do {
            try await transactor.exportData(to: Self.exportURL)
        } catch {
            print("Export Failed: \(error)")
        }
    }
    
    // true is success, false is failure
    public func importTransactionHistory(from url: URL) async -> Bool {
        do {
            try await transactor.importData(from: url)
        } catch {
            print("Import Failed: \(error)")
            return false
        }
        
        return true
    }
}
