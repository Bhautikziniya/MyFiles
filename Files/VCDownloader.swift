//
//  VCDownloader.swift
//  Vachnamrut
//
//  Created by agilemac-24 on 11/13/17.
//  Copyright © 2017 Agile Infoways. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Foundation

class VCDownloadObject:NSObject
{
    var type:String = ""
    var id:Int = -1
    var name:String = ""
    var aryVerseList:[VCAudio] = []
    var isDownloading:Bool = false
    
    override init() {
        super.init()
    }
    init(withType typeOfSection:String,wtihId id:Int,withName name:String )
    {
        self.type = typeOfSection
        self.id = id
        self.name = name
    }
}
class VCDownloaderForAllVerse:NSObject
{
    static let shared = VCDownloaderForAllVerse()
    
    var aryDownloadContentList:[VCDownloadObject] = []
    {
        didSet{
            if self.updateNavigationBarButtonWhenFinishDownloadHandler != nil
            {
                self.updateNavigationBarButtonWhenFinishDownloadHandler!()
            }
        }
    }
    
    var aryVerseList:[VCAudio] = []
    var isContinueDownling:Bool = false
    ///When one audio is download that time its called
    var didFinishCurrentDownloadAudioHandler:((Int)->())?
    
    ////When one section/subject/rp/favorite is complete that time refresh the tableview on below handler
    var reloadTableViewWhenFinishDataHandler:(()->())?
    
    ////When all items are download that time update the navigation button items
    var updateNavigationBarButtonWhenFinishDownloadHandler:(()->())?
    
    
    
    override init()
    {
        super.init()
        
    }
    func setData(withObject objDownload:VCDownloadObject)
    {
        if aryDownloadContentList.count > 0
        {
            self.aryDownloadContentList.append(objDownload)
            if self.isContinueDownling == false
            {
                objDownload.isDownloading = true
                self.aryVerseList = objDownload.aryVerseList
                self.startDownloade(withVerseIndex: 0, withListIndex: self.aryDownloadContentList.count - 1, completion: nil)
            }
            
        }
        else
        {
            objDownload.isDownloading = true
            self.aryDownloadContentList = [objDownload]
            self.aryVerseList = objDownload.aryVerseList
            self.startDownloade(withVerseIndex: 0, withListIndex: 0, completion: nil)
            
        }
    }
    
    func startDownloade(withVerseIndex vIndex:Int,withListIndex lIndex:Int ,completion: ((Bool, JSON) -> Void)?)
    {
        print("startDownloade List Index \(lIndex) ListArray Count \(self.aryDownloadContentList.count) Array Count \(self.aryVerseList.count) ")
        
        var listIndex:Int = lIndex
        if VCDownloader.shared.isContinueDownling == true || vIndex == self.aryVerseList.count || listIndex == self.aryDownloadContentList.count  || ReachabilityManager.shared.networkConnectionType == .disconnected
        {
            return
        }
        var isDownload:Bool = false
        if Vachnamrut.shared.downloadOnlyWifi == true
        {
            if ReachabilityManager.shared.networkConnectionType == .connectedViaWifi
            {
                isDownload = true
            }
        }
        else
        {
            isDownload = true
        }
        if isDownload == true
        {
            let backgroundQ =  DispatchQueue.global(qos: .background)
            backgroundQ.async
                {
                    if self.aryDownloadContentList.indices.contains(listIndex)
                    {
                        
                        self.aryDownloadContentList[listIndex].isDownloading = true
                        
                        if self.aryVerseList.indices.contains(vIndex)
                        {
                            let objAudio:VCAudio = self.aryVerseList[vIndex]
                            if !VCFileManager.shared.checkFileAvailableInDirectory(withFileType: .Audio, withFileName: objAudio.audioTitle)
                            {
                                let taskID = self.beginBackgroundUpdateTask()
                                let destination: DownloadRequest.DownloadFileDestination =
                                { _, _ in
                                    //let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                                    //directoryURL.appendingPathComponent("\(VCFileType.Audio.getDirectoryName())/\(objAudio.audioTitle)", isDirectory: false)
                                    let file = URL.init(fileURLWithPath: VCFileManager.shared.getLocalURLForFile(withFileType: .Audio, withFileName: objAudio.audioTitle))
                                    print(file)
                                    return (file, [.createIntermediateDirectories, .removePreviousFile])
                                }
                                Alamofire.download(objAudio.audioURL, method: .get, parameters: nil, encoding: JSONEncoding.default, to: destination).downloadProgress(closure: { (progress) in
                                    //progress closure
                                    //print("Download Progress: \(progress.fractionCompleted) \(objAudio.verseNo)")
                                    VCDownloaderForAllVerse.shared.isContinueDownling = true
                                    
                                    
                                }).responseJSON
                                    { response in
                                        
                                        if response.result.error == nil
                                        {
                                            completion?(true ,JSON(response.result.value as? NSDictionary ?? [:]))
                                        } else
                                        {
                                            print(#function, response.result.error?.localizedDescription ?? "")
                                            
                                        }
                                        
                                        Vachnamrut.shared.updateDownloadVerseInArray(withVerseNo: objAudio.verseNo)
                                        VCDownloaderForAllVerse.shared.isContinueDownling = false
                                        if VCDownloaderForAllVerse.shared.aryVerseList.count > 0
                                        {
                                            
                                            VCDownloaderForAllVerse.shared.aryVerseList.remove(at: 0)
                                             ///When one audio is download that time its called
                                            if self.didFinishCurrentDownloadAudioHandler != nil
                                            {
                                                self.didFinishCurrentDownloadAudioHandler!(VCDownloaderForAllVerse.shared.aryVerseList.count)
                                            }
                                            if VCDownloaderForAllVerse.shared.aryVerseList.count == 0
                                            {
                                                if VCDownloaderForAllVerse.shared.aryDownloadContentList.count > listIndex
                                                {
                                                VCDownloaderForAllVerse.shared.aryDownloadContentList[listIndex].aryVerseList = []
                                                    self.aryDownloadContentList[listIndex].isDownloading = false
                                                    //increase the lIndex varibalbe
                                                    listIndex = lIndex + 1
                                                    //VCDownloaderForAllVerse.shared.aryDownloadContentList.remove(at: 0)
                                                    
                                                    ////When one section/subject/rp/favorite is complete that time refresh the tableview on below handler
                                                    if self.reloadTableViewWhenFinishDataHandler != nil
                                                    {
                                                        self.reloadTableViewWhenFinishDataHandler!()
                                                    }
                                                    ///Check the alll the records
                                                    if VCDownloaderForAllVerse.shared.aryDownloadContentList.count  == listIndex
                                                    {
                                                        //VCDownloaderForAllVerse.shared.aryDownloadContentList = []
                                                        
                                                        VCDownloaderForAllVerse.shared.aryVerseList = []
                                                        
                                                    }
                                                    else
                                                    {
                                                        VCDownloaderForAllVerse.shared.aryVerseList = self.getVerseList(withVCDownloadObject: VCDownloaderForAllVerse.shared.aryDownloadContentList[listIndex])
                                                            //VCDownloaderForAllVerse.shared.aryDownloadContentList[0].aryVerseList
                                                    }
                                                    
                                                }
                                                else
                                                {
                                                    //VCDownloaderForAllVerse.shared.aryDownloadContentList = []
                                                    VCDownloaderForAllVerse.shared.aryDownloadContentList[listIndex].isDownloading = false
                                                    VCDownloaderForAllVerse.shared.aryDownloadContentList[listIndex].aryVerseList = []
                                                    VCDownloaderForAllVerse.shared.aryVerseList = []
                                                    ////When one section/subject/rp/favorite is complete that time refresh the tableview on below handler
                                                    if self.reloadTableViewWhenFinishDataHandler != nil
                                                    {
                                                        self.reloadTableViewWhenFinishDataHandler!()
                                                    }
                                                   
                                                }
                                            }
                                            
                                        }
                                        else
                                        {
                                            VCDownloaderForAllVerse.shared.aryDownloadContentList[listIndex].aryVerseList = []
                                            VCDownloaderForAllVerse.shared.aryVerseList = []
                                        }
                                        
                                        self.endBackgroundUpdateTask(taskID: taskID)
                                        self.startDownloade(withVerseIndex: 0, withListIndex: listIndex, completion: nil)
                                }
                            }
                            else
                            {
                                
                                Vachnamrut.shared.updateDownloadVerseInArray(withVerseNo: objAudio.verseNo)
                                
                                VCDownloaderForAllVerse.shared.isContinueDownling = false
                                if VCDownloaderForAllVerse.shared.aryVerseList.count > 0
                                {
                                    
                                    VCDownloaderForAllVerse.shared.aryVerseList.remove(at: 0)
                                    ///When one audio is download that time its called
                                    if self.didFinishCurrentDownloadAudioHandler != nil
                                    {
                                        self.didFinishCurrentDownloadAudioHandler!(VCDownloaderForAllVerse.shared.aryVerseList.count)
                                    }
                                    if VCDownloaderForAllVerse.shared.aryVerseList.count == 0
                                    {
                                        if VCDownloaderForAllVerse.shared.aryDownloadContentList.count > listIndex
                                        {
                                            VCDownloaderForAllVerse.shared.aryDownloadContentList[listIndex].aryVerseList = []
                                            
                                            self.aryDownloadContentList[listIndex].isDownloading = false
                                            //increase the lIndex varibalbe
                                            listIndex = lIndex + 1
                                            //VCDownloaderForAllVerse.shared.aryDownloadContentList.remove(at: 0)
                                            
                                            ////When one section/subject/rp/favorite is complete that time refresh the tableview on below handler
                                            if self.reloadTableViewWhenFinishDataHandler != nil
                                            {
                                                self.reloadTableViewWhenFinishDataHandler!()
                                            }
                                            ///Check the alll the records
                                            if VCDownloaderForAllVerse.shared.aryDownloadContentList.count  == listIndex
                                            {
                                                //VCDownloaderForAllVerse.shared.aryDownloadContentList = []
                                                
                                                VCDownloaderForAllVerse.shared.aryVerseList = []
                                                
                                            }
                                            else
                                            {
                                                VCDownloaderForAllVerse.shared.aryVerseList = self.getVerseList(withVCDownloadObject: VCDownloaderForAllVerse.shared.aryDownloadContentList[listIndex])
                                                //VCDownloaderForAllVerse.shared.aryDownloadContentList[0].aryVerseList
                                            }
                                            
                                        }
                                        else
                                        {
                                            //VCDownloaderForAllVerse.shared.aryDownloadContentList = []
                                            VCDownloaderForAllVerse.shared.aryDownloadContentList[listIndex].isDownloading = false
                                            VCDownloaderForAllVerse.shared.aryDownloadContentList[listIndex].aryVerseList = []
                                            VCDownloaderForAllVerse.shared.aryVerseList = []
                                            ////When one section/subject/rp/favorite is complete that time refresh the tableview on below handler
                                            if self.reloadTableViewWhenFinishDataHandler != nil
                                            {
                                                self.reloadTableViewWhenFinishDataHandler!()
                                            }
                                            
                                        }
                                    }
                                    
                                }
                                else
                                {
                                    VCDownloaderForAllVerse.shared.aryDownloadContentList[listIndex].aryVerseList = []
                                    VCDownloaderForAllVerse.shared.aryVerseList = []
                                }
                                
                                self.startDownloade(withVerseIndex: 0, withListIndex: listIndex, completion: nil)
                                
                            }
                        }
                    }
                    
            }
        }
    }
    //MARK:- Delete Process
    func deleteDownloadProcess(withIndex index:Int)
    {
    
        if VCDownloaderForAllVerse.shared.aryDownloadContentList.indices.contains(index)
        {
            VCDownloaderForAllVerse.shared.aryDownloadContentList.remove(at: index)
            self.cancelSingleRequest()
            
            ////When one section/subject/rp/favorite is complete that time refresh the tableview on below handler
            if self.reloadTableViewWhenFinishDataHandler != nil
            {
                self.reloadTableViewWhenFinishDataHandler!()
            }
            
        }
    }
    //MARK:- Cancel Request
    func cancelSingleRequest()
    {
        let sessionManager = Alamofire.SessionManager.default;
        
        sessionManager.session.getAllTasks { (dataTasks) in
            dataTasks.forEach { $0.cancel()
                // print("Cancel all request")
            };
        }
        
        sessionManager.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            dataTasks.forEach { $0.cancel()
                // // print("dataTasks :: Cancel all request")
            };
            uploadTasks.forEach { $0.cancel()
                // print("uploadTasks :: Cancel all request")
            };
            downloadTasks.forEach { $0.cancel()
                // print("downloadTasks :: Cancel all request ")
            }
        }
    }
    func cancelAllRequest() {
        
        let sessionManager = Alamofire.SessionManager.default;
        
        sessionManager.session.getAllTasks { (dataTasks) in
            dataTasks.forEach { $0.cancel()
                // print("Cancel all request")
            };
        }
        
        sessionManager.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            dataTasks.forEach { $0.cancel()
                // // print("dataTasks :: Cancel all request")
            };
            uploadTasks.forEach { $0.cancel()
                // print("uploadTasks :: Cancel all request")
            };
            downloadTasks.forEach { $0.cancel()
                // print("downloadTasks :: Cancel all request ")
                self.aryVerseList.removeAll()
                self.aryDownloadContentList.removeAll()
            }
        }
        
        
    }
    func getVerseList(withVCDownloadObject objDownload:VCDownloadObject) -> [VCAudio]
    {
        var aryTempVerseList:[VCAudio] = []
        if objDownload.type == GlobalLocalizationModel.shared.sectionLocalizedStr
        {
            aryTempVerseList = objDownload.aryVerseList
        }
        else if objDownload.type == GlobalLocalizationModel.shared.readingPlanLocalizedStr
        {
            var aryDownloadAllVerse:[VCAudio] = []
            for readingPlan in Vachnamrut.shared.aryReadingPlan
            {
                if readingPlan.rpID == objDownload.id
                {
                    for content in readingPlan.aryReadingPlanVerses
                    {
                        if let rpVerse:VCReadingPlanVerses = content as? VCReadingPlanVerses
                        {
                            
                            if rpVerse.verse.isAudioAvailable == true && rpVerse.verse.audio != nil
                            {
                                if rpVerse.verse.audio?.isLocalAudio == false
                                {
                                    aryDownloadAllVerse.append(rpVerse.verse.audio!)
                                }
                            }
                        }
                    }
                    break;
                }
            }
            aryTempVerseList = aryDownloadAllVerse
            
        }
        else if objDownload.type == GlobalLocalizationModel.shared.subjectLocalizedStr
        {
            aryTempVerseList = objDownload.aryVerseList
        }
        else if objDownload.type == GlobalLocalizationModel.shared.favouriteLocalizedStr
        {
            aryTempVerseList = objDownload.aryVerseList
        }
        return aryTempVerseList
    }
    
    //MARK:- Thread Management
    func beginBackgroundUpdateTask() -> UIBackgroundTaskIdentifier {
        return UIApplication.shared.beginBackgroundTask(expirationHandler: {})
    }
    
    func endBackgroundUpdateTask(taskID: UIBackgroundTaskIdentifier) {
        UIApplication.shared.endBackgroundTask(taskID)
    }
}
class VCDownloader: NSObject
{
    static let shared = VCDownloader()
    var aryMediaDownloader:[VCAudio] = []
    var didFinishCurrentDownloadAudioHandler:((VCAudio,Int)->())?
    var dictVerseList:[String:Any] = [:]
    
    var isContinueDownling:Bool = false
    override init()
    {
        super.init()
        
    }
    func setMedia(withMedia aryMedia:[VCAudio])
    {
        if self.aryMediaDownloader.count > 0 {
            self.aryMediaDownloader.append(contentsOf: aryMedia)
        } else {
            self.aryMediaDownloader = aryMedia
        }
        self.startDownloade(withIndex: 0, completion: nil)
        
    }
   
    
    func startDownloade(withIndex index:Int,completion: ((Bool, JSON) -> Void)?)
    {
        if VCDownloader.shared.isContinueDownling == true || index == self.aryMediaDownloader.count
        {
            return
        }
        var isDownload:Bool = false
        if Vachnamrut.shared.downloadOnlyWifi == true
        {
            if ReachabilityManager.shared.networkConnectionType == .connectedViaWifi
            {
                isDownload = true
            }
        }
        else
        {
            isDownload = true
        }
        if isDownload == true
        {
            let backgroundQ =  DispatchQueue.global(qos: .background)
            backgroundQ.async
                {
                    if self.aryMediaDownloader.indices.contains(index)
                    {
                        let objAudio:VCAudio = self.aryMediaDownloader[index]
                        if !VCFileManager.shared.checkFileAvailableInDirectory(withFileType: .Audio, withFileName: objAudio.audioTitle)
                        {
                            let taskID = self.beginBackgroundUpdateTask()
                            let destination: DownloadRequest.DownloadFileDestination =
                            { _, _ in
                                //let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                                //directoryURL.appendingPathComponent("\(VCFileType.Audio.getDirectoryName())/\(objAudio.audioTitle)", isDirectory: false)
                                let file = URL.init(fileURLWithPath: VCFileManager.shared.getLocalURLForFile(withFileType: .Audio, withFileName: objAudio.audioTitle))
                                print(file)
                                return (file, [.createIntermediateDirectories, .removePreviousFile])
                            }
                            Alamofire.download(objAudio.audioURL, method: .get, parameters: nil, encoding: JSONEncoding.default, to: destination).downloadProgress(closure: { (progress) in
                                //progress closure
                                //print("Download Progress: \(progress.fractionCompleted)")
                                VCDownloader.shared.isContinueDownling = true
                                
                                
                            }).responseJSON
                                { response in
                                   
                                if response.result.error == nil
                                {
                                    completion?(true ,JSON(response.result.value as? NSDictionary ?? [:]))
                                } else
                                {
                                    print(#function, response.result.error?.localizedDescription ?? "")
                                    
                                }
                                   
                                    
                                Vachnamrut.shared.updateDownloadVerseInArray(withVerseNo: objAudio.verseNo)
                                VCDownloader.shared.isContinueDownling = false
                                if VCDownloader.shared.aryMediaDownloader.count > 0 {
                                    VCDownloader.shared.aryMediaDownloader.remove(at: 0)
                                }
                                    
                                self.endBackgroundUpdateTask(taskID: taskID)
                                self.startDownloade(withIndex: 0, completion: nil)
                            }
                        }
                        else
                        {
                            
                            Vachnamrut.shared.updateDownloadVerseInArray(withVerseNo: objAudio.verseNo)
                            VCDownloader.shared.isContinueDownling = false
                            if VCDownloader.shared.aryMediaDownloader.count > 0 {
                                VCDownloader.shared.aryMediaDownloader.remove(at: 0)
                            }
                            self.startDownloade(withIndex: 0, completion: nil)
                            
                        }
                    }
            }
        }
    }
    
    //MARK:- Cancel Request
    func cancelAllRequest() {
        
        let sessionManager = Alamofire.SessionManager.default;
        
        sessionManager.session.getAllTasks { (dataTasks) in
            dataTasks.forEach { $0.cancel()
                // print("Cancel all request")
            };
        }
        
        sessionManager.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            dataTasks.forEach { $0.cancel()
                // // print("dataTasks :: Cancel all request")
            };
            uploadTasks.forEach { $0.cancel()
                // print("uploadTasks :: Cancel all request")
            };
            downloadTasks.forEach { $0.cancel()
                // print("downloadTasks :: Cancel all request ")
                self.aryMediaDownloader.removeAll()
            }
        }
        
    }
    
    //MARK:- Thread Management
    func beginBackgroundUpdateTask() -> UIBackgroundTaskIdentifier {
        return UIApplication.shared.beginBackgroundTask(expirationHandler: {})
    }
    
    func endBackgroundUpdateTask(taskID: UIBackgroundTaskIdentifier) {
        UIApplication.shared.endBackgroundTask(taskID)
    }
    
}
