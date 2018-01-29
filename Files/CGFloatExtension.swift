//
//  CGFloatExtension.swift
//  Vachnamrut
//
//  Created by Bhautik Ziniya on 9/14/17.
//  Copyright © 2017 Agile Infoways. All rights reserved.
//

import UIKit

extension Int{
    func getDurationString() -> String {
        var returnValue = ""
        
        let hours:Int = ((self % 86400) / 3600)
        let minutes:Int = ((self % 3600) / 60)
        
        if hours > 0{
            returnValue += "\(hours) \(hours > 1 ? "Hours" : "Hour")"
        }
        if minutes > 0{
            returnValue += " \(minutes) \(minutes > 1 ? "Minutes" : "Minute")"
        }
        
        return returnValue
    }
    
    func getHoursFromSeconds() -> Int {
        return ((self % 86400) / 3600)
    }
    func getMinutesFromSeconds() -> Int {
        return ((self % 3600) / 60)
    }
    func getSecondsFromSeconds() -> Int {
        return ((self % 3600) % 60)
    }
    
    func getDateFromSeconds() -> Date?{
        
       // print(String((self % 86400) / 3600) + " hours")
       // print(String((self % 3600) / 60) + " minutes")
       // print(String((self % 3600) % 60) + " seconds")
        
        let hours:Int = self.getHoursFromSeconds()
        let minutes:Int = self.getMinutesFromSeconds()
        let seconds:Int = self.getSecondsFromSeconds()
        
        let currentComponent = Calendar.current.dateComponents([Calendar.Component.day,Calendar.Component.month,Calendar.Component.year], from: Date())
        
        var dateComponent = DateComponents.init()
        dateComponent.day = currentComponent.day
        dateComponent.month = currentComponent.month
        dateComponent.year = currentComponent.year
        dateComponent.hour = hours
        dateComponent.minute = minutes
        dateComponent.second = seconds
        dateComponent.nanosecond = 0
        return NSCalendar.current.date(from: dateComponent)
    }
}

extension CGFloat {
    func proportionalFontSize() -> CGFloat {
        var sizeToCheckAgainst = self
        
        switch Devices.deviceType! {
        case .iPhone4or4s:
            sizeToCheckAgainst -= 2
            break
        case .iPhone5or5s:
            sizeToCheckAgainst -= 1
            break
        case .iPhone6or6s:
            sizeToCheckAgainst -= 0
            break
        case .iPhone6por6sp:
            sizeToCheckAgainst += 1
            break
        case .iPhoneX:
            sizeToCheckAgainst += 0
            break
        case .iPad:
            sizeToCheckAgainst += 10
            break
        
        }
        return sizeToCheckAgainst
    }
}
