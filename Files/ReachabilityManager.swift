//
//  ReachabilityManager.swift
//  Vachnamrut
//
//  Created by Bhautik Ziniya on 9/14/17.
//  Copyright © 2017 Agile Infoways. All rights reserved.
//

import UIKit
import ReachabilitySwift

class ReachabilityManager: NSObject
{
    
    //MARK: Shared Instance
    static let shared : ReachabilityManager = ReachabilityManager()
    
    fileprivate var reachability: Reachability?
    
    var networkConnectionType:NetworkConnection = .disconnected
    // NOTE: isAvailable is a getonly variable that returns the bool value if internet is available or not.
    
    var isInternetAvailable : Bool {
        get {
            if reachability == nil
            {
                setup()
            }
            
            return self.reachability!.isReachable || self.reachability!.isReachableViaWiFi || self.reachability!.isReachableViaWWAN
        }
    }
    
    fileprivate func setup() {
        self.reachability = Reachability()!
        
        do {
            try reachability!.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    // NOTE: If you are not using the delegate then you can use the block to identify or notify if internet is become available or lost.
    // to notify when internet become available use the below block.
    
    func connectionWhenReachable(_ reachableComplitionBlock: @escaping () -> ()) {
        if reachability == nil {
            self.setup()
        }
        
        reachability?.whenReachable = { reachable in
            reachableComplitionBlock()
            if (self.reachability?.isReachableViaWiFi)!
            {
                self.networkConnectionType = .connectedViaWifi
            }
            else
            {
                self.networkConnectionType = .connectedViaCellular
            }
            
            if VCDownloaderForAllVerse.shared.aryDownloadContentList.count > 0
            {
                VCDownloaderForAllVerse.shared.startDownloade(withVerseIndex: 0, withListIndex: 0, completion: nil)
            }
        }
    }
    
    // to notify when internet lost use the below block.
    
    func connectionWhenUnReachable(_ unReachableComplitionBlock: @escaping () -> ()) {
        if reachability == nil
        {
            self.setup()
        }
        
        reachability?.whenUnreachable = { unreachable in
            unReachableComplitionBlock()
            self.networkConnectionType = .disconnected
        }
    }
    
    deinit {
        reachability?.stopNotifier()
        reachability = nil
    }
}
