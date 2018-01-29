//
//  VCFileManager.swift
//  FMDBDemo
//
//  Created by agilemac-24 on 10/28/17.
//  Copyright © 2017 Agile Infoways pvt ltd. All rights reserved.
//

import UIKit

enum VCFileType {
    case Image
    case Document
    case Audio
    
    func getDirectoryName() -> String
    {
        switch self {
        case .Image:
            return "Images"
        case .Document:
            return "Document"
        case .Audio:
            return "Audio"
            
        }
    }
}

class VCFileManager:NSObject
{
    var documentDirectoryPath = ""
    static let shared:VCFileManager = VCFileManager()
    var fileManager:FileManager = FileManager()
    
    
    override init()
    {
        super.init()
        documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    }
    func checkFileAvailableInLocalDirectory(withFileName name:String) -> Bool
    {
        let strFilePath:String = documentDirectoryPath.appending("/\(name)")
        
        return self.fileManager.fileExists(atPath: strFilePath)
    }
    
    func checkFileAvailableInDirectory(withFileType fileType:VCFileType,withFileName name:String) -> Bool
    {
        
        var strFilePath:String = documentDirectoryPath.appending("/\(fileType.getDirectoryName())/\(Vachnamrut.shared.language.langID)")
        if self.fileManager.fileExists(atPath: strFilePath) != true
        {
            do
            {
                try FileManager.default.createDirectory(atPath: strFilePath, withIntermediateDirectories: true, attributes: nil)
                
            }
            catch let error as NSError
            {
               // print(error.localizedDescription);
            }
        }
        strFilePath = strFilePath.appending("/\(name)")
        
        return self.fileManager.fileExists(atPath: strFilePath)
        
    }
    
    func getLocalURLForFile(withFileType fileType:VCFileType,withFileName name:String) -> String
    {
        
        var strFilePath:String = documentDirectoryPath.appending("/\(fileType.getDirectoryName())/\(Vachnamrut.shared.language.langID)")
        if self.fileManager.fileExists(atPath: strFilePath) != true
        {
            do
            {
                try FileManager.default.createDirectory(atPath: strFilePath, withIntermediateDirectories: true, attributes: nil)
                
            }
            catch let error as NSError
            {
               // print(error.localizedDescription);
            }
        }
        strFilePath = strFilePath.appending("/\(name)")
        
        return strFilePath
        
    }
    
    func saveFile(at sourceFileLocation:String,to destinationFileLocation:String) -> Void
    {
        let aryContent:[String] = sourceFileLocation.components(separatedBy: ".")
        let fileName:String = aryContent.first!
        let fileType:String = aryContent.last!
        
        let sourceSqliteURLs = Bundle.main.url(forResource: fileName, withExtension: fileType)!
        let destinationSqliteURLs:URL = URL.init(fileURLWithPath: VCFileManager.shared.documentDirectoryPath.appending("/\(destinationFileLocation)"))
        
        do
        {
            try self.fileManager.copyItem(at: sourceSqliteURLs, to: destinationSqliteURLs)
        }
        catch{
           // print(error.localizedDescription)
        }
    }
    
    func getFolderSize(forFileType type: VCFileType, withLangID langId: Int) -> String {
        
        let path = documentDirectoryPath.appending("/\(type.getDirectoryName())/\(langId)")
        
        do {
            
            // Get the directory contents urls (including subfolders urls)
            let url = URL.init(fileURLWithPath: path)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            
//            // if you want to filter the directory contents you can do like this:
//            let mp3Files = directoryContents.filter{ $0.pathExtension == "mp3" }
//           // print("mp3 urls:",mp3Files)
//            let mp3FileNames = mp3Files.map{ $0.deletingPathExtension().lastPathComponent }
//           // print("mp3 list:", mp3FileNames)
            
            var totalBytes: UInt64 = 0
            
            for file in directoryContents {
                let fileAttributes = try FileManager.default.attributesOfItem(atPath: file.relativePath)
                guard let fileSize = fileAttributes[FileAttributeKey.size] as? NSNumber else { continue }
                totalBytes += fileSize.uint64Value
            }
            
            guard totalBytes > 0 else {
                return "0 MB"
            }
            
            let countBytes = ByteCountFormatter()
            countBytes.allowedUnits = [.useMB]
            countBytes.countStyle = .file
            let totalSize = countBytes.string(fromByteCount: Int64(totalBytes))
            
           // print("\(#function, #line) File size: \(totalSize)")
            return totalSize
        } catch {
           // print(error.localizedDescription)
            return ""
        }
    }
    
    func getFolderSize(forFileType type: VCFileType) -> String {
        
        let path = documentDirectoryPath.appending("/\(type.getDirectoryName())")
        
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: URL.init(fileURLWithPath: path), includingPropertiesForKeys: nil, options: [])
    
            var totalBytes: UInt64 = 0
            
            for dir in directoryContents {
                if dir.hasDirectoryPath {
                    let subDirectoryContents = try FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil, options: [])
                    
                    for file in subDirectoryContents {
                        let fileAttributes = try FileManager.default.attributesOfItem(atPath: file.relativePath)
                        guard let fileSize = fileAttributes[FileAttributeKey.size] as? NSNumber else { continue }
                        totalBytes += fileSize.uint64Value
                    }
                }
            }
            
            guard totalBytes > 0 else {
                return "0 KB"
            }
            
            let countBytes = ByteCountFormatter()
            countBytes.allowedUnits = [.useKB,.useMB,.useGB,.useTB]
            countBytes.countStyle = .file
            let totalSize = countBytes.string(fromByteCount: Int64(totalBytes))
           // print("\(#function, #line) File size: \(totalSize)")
            return totalSize
            
        } catch {
           // print(error.localizedDescription)
            return ""
        }
    }
    
    @discardableResult
    func removeFiles(forType type: VCFileType) -> Bool {
        var path = documentDirectoryPath.appending("/\(type.getDirectoryName())")
        
        do {
            try FileManager.default.removeItem(atPath: path)
            
            path = documentDirectoryPath.appending("/\(type.getDirectoryName())/\(Vachnamrut.shared.language.langID)")
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            
            return true
//            // Get the directory contents urls (including subfolders urls)
//            let url = URL.init(fileURLWithPath: path)
//            let directoryContents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
//
//            for file in directoryContents {
//                try FileManager.default.removeItem(at: file)
//            }
        } catch {
           // print(error.localizedDescription)
            return false
        }
    }
    
}

