//
//  DateExtension.swift
//  Vachnamrut
//
//  Created by agilemac-24 on 11/4/17.
//  Copyright © 2017 Agile Infoways. All rights reserved.
//
import Foundation
import UIKit

extension Date
{
    func isBetween(_ date1: Date, and date2: Date) -> Bool {
        return (min(date1, date2) ... max(date1, date2)).contains(self)
    }
    
    func toLocalTime() -> Date {
        let tz = NSTimeZone.local
        let seconds: Int = tz.secondsFromGMT(for: self)
        return Date(timeInterval: TimeInterval.init(seconds), since: self)
    }
    
    func toGlobalTime() -> Date {
        
        let tz = NSTimeZone.local
        let seconds: Int = -tz.secondsFromGMT(for: self)
        return Date(timeInterval: TimeInterval.init(seconds), since: self)
    }
    
    func date(ByAddingDays days:Int) -> Date {
        return Calendar.current.date(byAdding: Calendar.Component.day, value: days, to: self)!
    }
    
    /// In database Time stored in hh.mm a format e.g. { 9.00 PM }
    ///
    /// - Returns: time of date in hh.mm a format
    func getDatabaseStringFromDate() -> String{
         
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: self)
    }
    
    func isDateExceedReminderTime() -> Bool {
         
        if let reminderDate = Vachnamrut.shared.reminderTime
        {
            if reminderDate.hour > Date().hour{
                return false
            }else if reminderDate.hour < Date().hour{
                return true
            }else if reminderDate.hour == Date().hour{
                
                if reminderDate.minute > Date().minute{
                    return false
                }else if reminderDate.minute < Date().minute{
                    return true
                }else if reminderDate.minute == Date().minute{
                    return true
                }
            }
        }
        return false
    }
    
    func isCurrentDay() -> Bool{
        let currentComponent = Calendar.current.dateComponents([Calendar.Component.day,Calendar.Component.month,Calendar.Component.year], from: Date())
        
        let component = Calendar.current.dateComponents([Calendar.Component.day,Calendar.Component.month,Calendar.Component.year], from: self)
        
        return (currentComponent.day == component.day && currentComponent.month == component.month && currentComponent.year == component.year)
    }
    
    func getTotalSecondsFromDate() -> Int {
        var component = Calendar.current.dateComponents([Calendar.Component.minute,Calendar.Component.hour], from: self)
        component.day = 0
        component.month = 0
        component.year = 0
        
        var totalSeconds:Int = 0
        if let hour = component.hour{
            totalSeconds += (hour * 60 * 60)
        }
        if let minute = component.minute{
            totalSeconds += (minute * 60 )
        }
        
        return totalSeconds // ((component.hour * 60) + component.minute)
    }

    func convertDateInUTCDateString(withDateFormat format:String, withConvertedDateFormat convertDate:String) -> String
    {
        var strConvertedDate:String = ""
        
        let dateFormat:DateFormatter = DateFormatter()
        dateFormat.dateFormat = format
        strConvertedDate = dateFormat.string(from: self)
        let convertedDate:Date = dateFormat.date(from: strConvertedDate)!;
        dateFormat.dateFormat = convertDate
        dateFormat.timeZone = TimeZone(abbreviation: "UTC")
        strConvertedDate = dateFormat.string(from: convertedDate);
        return strConvertedDate
    }
    
    func convertLocalDateToUTCDate(date:String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.calendar = NSCalendar.current
        dateFormatter.timeZone = TimeZone.current
        
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return dateFormatter.string(from: dt!)
    }
    func getDateInString(withFormat format:String) -> String
    {
        var strConvertedDate:String = ""
        
        let dateFormat:DateFormatter = DateFormatter()
        dateFormat.dateFormat = format
        strConvertedDate = dateFormat.string(from: self)
        
        return strConvertedDate
    }
    func getSeconds(fromDate toDate:Date) -> Int
    {
        let elapsed = self.timeIntervalSince(toDate)
        return Int(elapsed)
    }
//    func getDateInString(withFormat format:String) -> String
//    {
//        var strConvertedDate:String = ""
//
//        let dateFormat:DateFormatter = DateFormatter()
//        dateFormat.dateFormat = format
//        strConvertedDate = dateFormat.string(from: self)
//
//        return strConvertedDate
//    }
    
    static func getCurrentDate() -> Date
    {
        let currentDate:Date = Date()
        let dateFormat:DateFormatter = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormat.timeZone = TimeZone(abbreviation: "UTC")
        dateFormat.calendar = NSCalendar.current
        
        let strCurrentDate:String = dateFormat.string(from: currentDate)
        if let convertedDate:Date  = dateFormat.date(from: strCurrentDate)
        {
            return convertedDate
        }
        else
        {
            return currentDate
        }
        
        /*
        let currentDate:Date = Date()
        let dateFormat:DateFormatter = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormat.timeZone = TimeZone(abbreviation: "UTC")
        dateFormat.calendar = NSCalendar.current
        
        let strCurrentDate:String = currentDate.getDateInString(withFormat: "yyyy-MM-dd HH:mm:ss")
        if let convertedDate:Date  = dateFormat.date(from: strCurrentDate)
        {
            return convertedDate
        }
        else
        {
            return currentDate
        }
        */
    }
    static func getCurrentDateInString() -> String
    {
        let currentDate:Date = Date()
        let dateFormat:DateFormatter = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormat.timeZone = TimeZone(abbreviation: "UTC")
        dateFormat.calendar = NSCalendar.current
        
        let strCurrentDate:String = currentDate.getDateInString(withFormat: "yyyy-MM-dd HH:mm:ss")
        return strCurrentDate
    }
    
    var getTime: String {
        let timeFormat: DateFormatter = DateFormatter()
        timeFormat.timeStyle = .short
        timeFormat.timeZone = TimeZone.current
//        timeFormat.timeZone = TimeZone(abbreviation: "GMT")
        timeFormat.calendar = NSCalendar.current
        
        let str = timeFormat.string(from: self)
        return str
    }
    
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    var week: Int {
        return Calendar.current.component(.weekOfYear, from: self)
    }
    
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }
    
    var minute: Int {
        return Calendar.current.component(.minute, from: self)
    }
    
    var second: Int {
        return Calendar.current.component(.second, from: self)
    }
    
}
