//
//  ApiServicesManager.swift
//  Vachnamrut
//
//  Created by Bhautik Ziniya on 9/14/17.
//  Copyright © 2017 Agile Infoways. All rights reserved.
//

import UIKit
import Alamofire

class ApiServicesManager: NSObject {
    
    //MARK: Shared Instance
    static let shared : ApiServicesManager = ApiServicesManager()
    
    func GET(_ url: String, withCompletion handler: @escaping (DataResponse<Any>) -> Void) {
        if ReachabilityManager.shared.isInternetAvailable {
            Alamofire.request(url, method: .get, parameters: nil).responseJSON(completionHandler: handler)
        } else {
            UIAlertController.showNoInternetConnectionAlert()
        }
    }
    
    func POST(_ url: String, params: [String : Any]?, withCompletion handler: @escaping (DataResponse<Any>) -> Void) {
        if ReachabilityManager.shared.isInternetAvailable {
            Alamofire.request(url, method: .post, parameters: params).responseJSON(completionHandler: handler)
        } else {
            UIAlertController.showNoInternetConnectionAlert()
        }
    }
}
