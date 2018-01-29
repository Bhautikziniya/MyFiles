//
//  UIDeviceExtension.swift
//  Vachnamrut
//
//  Created by Bhautik Ziniya on 9/14/17.
//  Copyright © 2017 Agile Infoways. All rights reserved.
//

import UIKit

extension UIDevice {
    
    static var isPortrait : Bool {
        return UIDevice.current.orientation.isPortrait
    }
    
    static var isLandscape : Bool {
        return UIDevice.current.orientation.isLandscape
    }
}
