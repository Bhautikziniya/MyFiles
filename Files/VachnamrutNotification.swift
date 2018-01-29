//
//  VachnamrutNotification.swift
//  Vachnamrut
//
//  Created by Bhautik Ziniya on 11/29/17.
//  Copyright © 2017 Agile Infoways. All rights reserved.
//

import UIKit
import UserNotifications

class VachnamrutNotification: NSObject {
    
    // UserInfoKeys
    private let kNotificationId = "Notification_ID"
    private let kNotificationDate = "Notification_Date"
    private let kNotificationDateString = "Notification_DateStr" //Value : e.g dd-MM-yyyy
    private let kNotificationTime = "Notification_TimeStr" //Value : e.g HH:mm
    private let kNotificationDateFormat = "dd-MM-yyyy"
    private let kNotificationTimeFormat = "HH:mm"

    /// Shared Instance
    static let shared: VachnamrutNotification = VachnamrutNotification()
    
    //MARK:- Private Helpers
    /// Repeat Notification Interval.
    private var notificationRepeatInterval:[Int] = [1,2,5]
    
    /// This will have total duration of verse read today.
    private var totalVerseReadDurationForToday:Int{
        get{
            return VCUserDB.shared.getTotalVerseReadingTimeInSeconds() 
        }
    }
    
    /// This will have total duration of verse target today in seconds.
    private var totalVerseReadDurationTargetForToday:Int{
        get{
            return Vachnamrut.shared.readingPlanDurationTime
        }
    }
    
    /// This will have total verse mark as read today.
    private var totalVerseReadToday:Int{
        get{
            return VCUserDB.shared.getTotalVerseMarkAsRead()
        }
    }
    
    /// Number of verse reading target
    private var totalDailyVerseReadTarget:Int{
        get{
            return Vachnamrut.shared.noOfDailyVerses
        }
    }
    
    //MARK:- Initialize
    override init() {
        super.init()
        self.registerForNotification()
    }
    //MARK:- Authentication
    private func registerForNotification() {
        //Requesting Authorization for User Interactions
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            
            center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                // Enable or disable features based on authorization.
                if granted {
                   // print("granted")
//                    self.removeAllPendingNotification()
//                    for index in 1..<60{
//                        self.scheduleNotification(atDate: Calendar.current.date(byAdding: Calendar.Component.second, value: index*5, to: Date())!, RepeatInterval: 0)
//                    }
                } else {
                   // print("denied")
                }
            }
        } else {  UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert], categories: nil))
        }
    }
    
    private func scheduleNotificationForToday(currentDate:Date = Date()) -> Void{
        // Schedule Notification For Current Day
        if currentDate.isDateExceedReminderTime() == false   {
            
            switch Vachnamrut.shared.readingTargetType {
                case .Count:
                    if self.totalVerseReadToday < self.totalDailyVerseReadTarget{
                        self.scheduleNotification(atDate: currentDate)
                    }
                    break
                case .Time:
                    if self.totalVerseReadDurationForToday < self.totalVerseReadDurationTargetForToday{
                        self.scheduleNotification(atDate: currentDate)
                    }
                    break
                case .none:
                    break
                case .some(_):
                    break
            }
        }
    }
    
    private func scheduleNotification(atDate date: Date,RepeatInterval intervalFromCurrentDay:Int = 0) {
        
        var dateComponents = DateComponents()
        dateComponents.hour = Vachnamrut.shared.reminderTime.hour
        dateComponents.minute = Vachnamrut.shared.reminderTime.minute
        dateComponents.second = 0
        dateComponents.nanosecond = 0
        dateComponents.day = date.day
        dateComponents.month = date.month
        dateComponents.year = date.year
        
        let titleForNotification = "Reading Target Reminder"
        let bodyForNotification = self.getNotificationBody(ForDate: date)
        let userInfoForNotification:[AnyHashable:Any] = [
            kNotificationId:"Notification_\(intervalFromCurrentDay)",
            kNotificationDateString:date.getDateInString(withFormat: kNotificationDateFormat),
            kNotificationTime:date.getDateInString(withFormat: kNotificationTimeFormat),
            kNotificationDate:date
        ]
        
        if #available(iOS 10.0, *) {
            //iOS 10 or above version
            let content = UNMutableNotificationContent()
            content.title = titleForNotification
            content.body = bodyForNotification
            content.sound = UNNotificationSound.default()
            content.userInfo = userInfoForNotification
           
            let trigger1 = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier:userInfoForNotification[kNotificationId] as! String, content: content, trigger: trigger1)
            
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().add(request){(error) in
                if error != nil {
                   // print(error?.localizedDescription ?? "")
                }
            }
        } else {
            // iOS 9
            let notification = UILocalNotification()
            notification.fireDate = date
            notification.alertTitle = titleForNotification
            notification.alertBody = bodyForNotification
            notification.soundName = UILocalNotificationDefaultSoundName
            notification.userInfo = userInfoForNotification
            UIApplication.shared.scheduleLocalNotification(notification)
            
        }
    }
    
    private func getNotificationBody(ForDate date:Date) -> String {
        if Vachnamrut.shared.readingTargetType == .Count{
            return "You have \(date.isCurrentDay() == true ? (self.totalDailyVerseReadTarget - self.totalVerseReadToday) : self.totalDailyVerseReadTarget) verse remaining to read Today"
        }else if Vachnamrut.shared.readingTargetType == .Time{
            
            var returnValue = "You have "
            var secondsToParse:Int = 0
            
            if date.isCurrentDay() == true{
                secondsToParse = self.totalVerseReadDurationTargetForToday - self.totalVerseReadDurationForToday
            }else{
                secondsToParse = self.totalVerseReadDurationTargetForToday
            }
            
            let duration: TimeInterval = TimeInterval.init(secondsToParse)
            let formatter = DateComponentsFormatter() 
            formatter.unitsStyle = .full
            
            let hours = secondsToParse.getHoursFromSeconds()
            let minutes = secondsToParse.getMinutesFromSeconds()
            let seconds = secondsToParse.getSecondsFromSeconds()
            
            if hours > 0 && minutes > 0 && seconds > 0{
                formatter.allowedUnits = [.minute,.second,.hour]
            }
            else if hours > 0 && seconds > 0{
                formatter.allowedUnits = [.second,.hour]
            }
            else if hours > 0 && minutes > 0{
                formatter.allowedUnits = [.minute,.hour]
            }
            else if minutes > 0 && seconds > 0{
                formatter.allowedUnits = [.minute,.second]
            }
            else if hours > 0{
                formatter.allowedUnits = [.hour]
            }
            else if minutes > 0{
                formatter.allowedUnits = [.minute]
            }
            else if seconds > 0{
                formatter.allowedUnits = [.second]
            }
            formatter.zeroFormattingBehavior = [.pad] 
            returnValue += "\(String(describing: formatter.string(from: duration)!)) remaining to read Today"
            
            return returnValue
        }else{
            return "Failed to handle body.. Due to new type added in "
        }
    }
    
    private func showAllPendingNotifications() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
               // print(notificationRequests.count)
            }
        } else {
            // Fallback on earlier versions
           // print(UIApplication.shared.scheduledLocalNotifications?.count ?? "")
        }
    }
}

//MARK:- Public Methods
extension VachnamrutNotification {
    
    public func scheduleNotificationFromCurrentDate() -> Void{
        
        // Remove Existing Notifications First
        self.removeAllPendingNotification()
        
        // Current Date
        let currentDate = Date()
        
        // Schedule Notification For TODAY
        self.scheduleNotificationForToday(currentDate: currentDate)
        
        // Schedule Notification For Repeat Days
        for repeatDay in self.notificationRepeatInterval{
            self.scheduleNotification(atDate: currentDate.date(ByAddingDays: repeatDay), RepeatInterval: repeatDay)
        }
    }
    
    public func updateTodaysScheduleNotificationContent() -> Void {
        // Fetch Number of verse readed with below query
        // For Count : select count(*) from verseStatistics where startDate = '10-12-2017' and markedAsRead = 1
        // For Time : SELECT SUM(duration) FROM verseStatistics WHERE startDate = '10-12-2017'
        // Update Notification Details for current date reminder.
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
                for notification in notificationRequests{
                    if let strDateOfNotification = notification.content.userInfo[self.kNotificationDateString] as? String{
                        if strDateOfNotification == Date().getDateInString(withFormat: self.kNotificationDateFormat){
                            // Remove Existing Notification
                            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.content.userInfo[self.kNotificationId] as! String])
                           // print("Notification Removed For Today")
                            self.scheduleNotificationForToday()
                           // print("Notification Removed Reschedule May be")
                        }
                    }
                }
            }
        } else {
            // Fallback on earlier versions
            if let allLocalNotifications = UIApplication.shared.scheduledLocalNotifications{
                for notification in allLocalNotifications{
                    if let info = notification.userInfo{
                        if let strDateOfNotification = info[self.kNotificationDateString] as? String{
                            if strDateOfNotification == Date().getDateInString(withFormat: self.kNotificationDateFormat){
                                // Remove Existing Notification
                                UIApplication.shared.cancelLocalNotification(notification)
                               // print("Notification Removed For Today")
                                self.scheduleNotificationForToday()
                               // print("Notification Removed Reschedule May be")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func removeAllPendingNotification() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        } else {
            // Fallback on earlier versions
            UIApplication.shared.scheduledLocalNotifications?.removeAll()
        }
    }
}

@available(iOS 10.0, *)
extension VachnamrutNotification : UNUserNotificationCenterDelegate {
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        //// print("Tapped in notification")
    }
    
    //This is key callback to present notification while the app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //// print("Notification being triggered")
        //You can either present alert ,sound or increase badge while the app is in foreground too with ios 10
        //to distinguish between notifications
//        if notification.request.identifier == requestIdentifier {
            completionHandler( [.alert,.sound,.badge])
//        }
    }
}
