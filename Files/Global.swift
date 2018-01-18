//
//  Global.swift
//  test
//
//  Created by Bhautik Ziniya on 1/19/18.
//  Copyright © 2018 Agile Infoways. All rights reserved.
//

import Foundation
import UIKit

/*
 get the free disk space in the device to avoid recording issue.
 */

struct AppSize {
    static var minimumStorageSpace:UInt64 = 500
    /// Returns free disk space
    static var getFreeDiskSpace : (totalSize: UInt64, freeSize: UInt64) {
        var totalSpace : UInt64?
        var totalFreeSpace : UInt64?
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        var dict : [FileAttributeKey : Any]?
        
        do {
            dict = try FileManager.default.attributesOfFileSystem(forPath: paths.last!)
        } catch let error as NSError {
             print(error.localizedDescription)
        }
        
        if dict != nil {
            let fileSystemSizeInBytes = dict![FileAttributeKey.systemSize] as! NSNumber
            let freeFileSystemSizeInBytes = dict![FileAttributeKey.systemFreeSize] as! NSNumber
            totalSpace = fileSystemSizeInBytes.uint64Value
            totalFreeSpace = freeFileSystemSizeInBytes.uint64Value
            // print("Memory Capacity of \((totalSpace!/1024)/1024) MB with \((totalFreeSpace!/1024)/1024) MB Free memory available.")
        }
        
        return ((totalSpace!/1024)/1024,(totalFreeSpace!/1024)/1024)
    }
}

struct AppUtility {
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        
        self.lockOrientation(orientation)
        
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
    
    /// OPTIONAL Added method to rotate to the desired orientation
    static func rotate(to orientation: UIInterfaceOrientation) {
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
    }
    
}
