//
//  VCSettings.swift
//  Vachnamrut
//
//  Created by Bhautik Ziniya on 10/23/17.
//  Copyright © 2017 Agile Infoways. All rights reserved.
//

import Foundation

class VCSettingRow : NSObject {
    
    var settingType:SettingsRowType = SettingsRowType.none
    var name:String = ""
    var accessoryTitle: String = ""
    var detailTitle: String = ""
    var icon: String = ""
    var rowType: SettingsRow = .none
    var fromLabel: String = ""
    var toLabel: String = ""
    var fromTime: String = ""
    var toTime: String = ""
    
    init(name:String, accessoryTitle: String? = nil, detailTitle: String? = nil, icon: String? = nil, fromLabel: String? = nil, toLabel: String? = nil, fromTime: String? = nil, toTime: String? = nil, type:SettingsRowType, rowType: SettingsRow) {
        self.name = name
        self.settingType = type
        self.rowType = rowType
        
        if let title = accessoryTitle {
            self.accessoryTitle = title
        }
        
        if let dtlTitle = detailTitle {
            self.detailTitle = dtlTitle
        }
        
        if let icn = icon {
            self.icon = icn
        }
        
        if let label = fromLabel {
            self.fromLabel = label
        }
        
        if let label = toLabel {
            self.toLabel = label
        }
        
        if let time = fromTime {
            self.fromTime = time
        }
        
        if let time = toTime {
            self.toTime = time
        }
    }
}


class VCSetting : NSObject {
    
    var settingType:SettingsSections = SettingsSections.none
    var name: String = ""
    var arrChildOptions = [VCSettingRow]()
    
    init(type:SettingsSections, childOptions:[VCSettingRow], name: String) {
        self.settingType = type
        self.name = name
        self.arrChildOptions = childOptions
    }
    
}
