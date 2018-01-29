//
//  AIImagePickerController.swift
//  GoodBuysShopper
//
//  Created by Dhaval Nena on 22/06/17.
//  Copyright © 2017 Agile. All rights reserved.
//


import Foundation
import UIKit
import AVFoundation

enum AIImagePickerOption:Int{
    
    case
    camera,
    savedPhotosAlbum,
    photoLibrary,
    askForOption
    
    var name:String {
        switch self {
        case .photoLibrary:
            return "Photo Library"
        case .camera:
            return "Camera"
        case .savedPhotosAlbum:
            return "Saved Photos Album"
        case .askForOption:
            return "Ask for option"
        }
    }
}

class AIImagePickerController: UIImagePickerController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK:- PROPERTIES
    var blockCompletion:((_ isCancelled:Bool,_ pickedImage:UIImage?) -> Void)?
    var option:AIImagePickerOption = .photoLibrary
    
    // MARK: - SHARED MANAGER
    static let shared = AIImagePickerController()
    
    
    //MARK:- SHOW IMAGE PICKER
    
    
    func showImagePickerFrom(vc:UIViewController, withOption option:AIImagePickerOption, andCompletion completion:@escaping ((_ isCancelled:Bool,_ pickedImage:UIImage?) -> Void)){
        
        self.blockCompletion = completion
        
        if(option == .askForOption){
            let options:[String] = [AIImagePickerOption.camera.name,
                                    AIImagePickerOption.savedPhotosAlbum.name,
                                    AIImagePickerOption.photoLibrary.name]
            showActionSheetWithTitleFromVC(vc: vc, title: "Choose Option", andMessage: "", buttons: options, canCancel: true, completion: { (index) in
                print("selected option : \(index)")
                
                if(index == options.count){
                    if(self.blockCompletion != nil){
                        self.blockCompletion!(false, nil)
                    }
                    return
                }
                self.option = AIImagePickerOption(rawValue: index)!
                self.checkPermissionAndProceedFurther(vc: vc)
            })
        }else{
            self.option = option
            checkPermissionAndProceedFurther(vc: vc)
        }
    }
    
    private func checkPermissionAndProceedFurther(vc:UIViewController){
        
        let cameraMediaType = AVMediaTypeVideo
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: cameraMediaType)
        
        var strMessage = ""
        switch cameraAuthorizationStatus {
        case .denied:
            strMessage = "image : denied"
        case .authorized:
            strMessage = "image : authorized"
        case .restricted:
            strMessage = "image : restricted"
        case .notDetermined:
            strMessage = "image : notDetermined"
        }
        print("IMAGE PERMISSION : \(strMessage)")
        
        if(cameraAuthorizationStatus == .authorized){
            takeOrSelectPhotoFrom(vc: vc)
        }else{
            
            var shouldAlertForGoToSetting:Bool = false
            if(cameraAuthorizationStatus == .notDetermined){
                AVCaptureDevice.requestAccess(forMediaType: cameraMediaType) { granted in
                    if granted {
                        print("Granted access to \(cameraMediaType)")
                        self.takeOrSelectPhotoFrom(vc: vc)
                    } else {
                        print("Denied access to \(cameraMediaType)")
                        shouldAlertForGoToSetting = true
                    }
                }
            }else{
                shouldAlertForGoToSetting = true
            }
            
            if(shouldAlertForGoToSetting){
                showAlertWithTitleFromVC(vc: vc, title: APP_NAME, andMessage: "App needs permission to take photo from your library, go to settings and allow access", buttons: ["Dismiss","Settings"], completion: { (index) in
                    if(index == 1){
                        if let url = URL(string: UIApplicationOpenSettingsURLString) {
                            
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            } else {
                                UIApplication.shared.openURL(url)
                            }
                        }
                    }
                })
            }
        }
    }
    
    
    private func takeOrSelectPhotoFrom(vc:UIViewController){
        
        if self.option == .camera{
            
            if !UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.rear) {
                showAlertWithTitleFromVC(vc: vc, title: APP_NAME, andMessage: "Device is not compatible for the required operation", buttons: ["Dismiss"], completion: { (index) in
                    if(self.blockCompletion != nil){
                        self.blockCompletion!(false, nil)
                    }
                })
                return
            }
        }
        
        
        self.delegate = self
        self.allowsEditing = true//false
        
        switch self.option {
        case .photoLibrary:
            self.sourceType = .photoLibrary
        case .savedPhotosAlbum:
            self.sourceType = .savedPhotosAlbum
        case .camera:
            self.sourceType = .camera
        default:
            break
        }
        
        if(UIImagePickerController.isSourceTypeAvailable(self.sourceType)){
            vc.present(self, animated: true) {
            }
        }else{
            showAlertWithTitleFromVC(vc: vc, title: APP_NAME, andMessage: "Device is not compatible for the required operation", buttons: ["Dismiss"], completion: { (index) in
                if(self.blockCompletion != nil){
                    self.blockCompletion!(false, nil)
                }
            })
        }
    }
    
    //MARK:- DELEGATE
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let imageKey = picker.allowsEditing ? UIImagePickerControllerEditedImage : UIImagePickerControllerOriginalImage
        if let pickedImage = info[imageKey] as? UIImage {
            
            if(self.blockCompletion != nil){
                self.blockCompletion!(true, pickedImage)
            }
        }else{
            if(self.blockCompletion != nil){
                self.blockCompletion!(true, nil)
            }
        }
        
        
        dismiss(animated: true) {
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        if(self.blockCompletion != nil){
            self.blockCompletion!(false, nil)
        }
        
        dismiss(animated: true) {
        }
    }
}
