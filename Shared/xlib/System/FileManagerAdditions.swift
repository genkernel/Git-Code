//
//  FileManagerAdditions.swift
//
//  Created by Altukhov Anton on 20.06.16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

public extension FileManager {
	
    func isFileExistent(atPath path: String) -> Bool {
        var isDirectory = false
        let exists = isExistent(atPath: path, isDirectory: &isDirectory)
        
        return exists && !isDirectory
    }
    
    func isDirectoryExistent(atPath path: String) -> Bool {
        var isDirectory = false
        let exists = isExistent(atPath: path, isDirectory: &isDirectory)
        
        return exists && isDirectory
    }
    
	func isExistent(atPath path: String, isDirectory: inout Bool) -> Bool {
		var directory = ObjCBool(false)
		let exists = FileManager.default.fileExists(atPath: path, isDirectory: &directory)
		
		isDirectory = directory.boolValue
		return exists
	}
	
    // MARK:
    
    func createDirectoryIfNotExists(atPath path: String) -> Bool {
        var created: Bool
        
        if isDirectoryExistent(atPath: path) {
            created = true
        } else {
            do {
                try createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                
                created = true
            } catch let error as NSError {
                print("Failed to create directory at path: \(path). \(error)")
                
                created = false
            }
        }
        
        return created
    }
    
    func deleteDirectoryAndItsContents(atPath path: String) -> Bool {
        var didDeleteAllContent = true
        
        enumerator(atPath: path)?.forEach {
            if let itemName = $0 as? String {
                let itemPath = path.appending("/\(itemName)")
                
                var isDirectory = ObjCBool(false)
                let _ = fileExists(atPath: itemPath, isDirectory: &isDirectory)
                
				let isThisDirectory = isDirectory.boolValue
				
				let isDeleted: Bool
				if isThisDirectory {
					isDeleted = deleteDirectoryAndItsContents(atPath: itemPath)
                } else {
                    do {
                        try removeItem(atPath: itemPath)
                        
                        isDeleted = true
                    } catch {
                        isDeleted = false
                    }
                }
                
                didDeleteAllContent = didDeleteAllContent && isDeleted
            }
        }
        
        do {
            try removeItem(atPath: path)
        } catch {
            didDeleteAllContent = false
        }
        
        return didDeleteAllContent
    }
	
}
