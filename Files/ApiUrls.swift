//
//  ApiUrls.swift
//  Vachnamrut
//
//  Created by Bhautik Ziniya on 9/14/17.
//  Copyright © 2017 Agile Infoways. All rights reserved.
//

import Foundation

class ApiUrls {
    
    // MARK: get full url by passing the path url (baseURL + pathUrl)
    fileprivate static func getAbsoluteUrl(_ pathUrl : String) -> String {
        return ApiUrls.BaseURL + pathUrl
    }
    
    // Base url
    static var BaseURL = ""
    
    // Path urls
    static var Login = getAbsoluteUrl("")
    
}
