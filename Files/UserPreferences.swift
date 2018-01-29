//
//  UserDefaults.swift
//  Vachnamrut
//
//  Created by Bhautik Ziniya on 9/18/17.
//  Copyright © 2017 Agile Infoways. All rights reserved.
//

import UIKit

class UserPreferences: NSObject {
    
    //MARK: Shared Instance
    static let shared : UserPreferences = UserPreferences()
    
    //MARK: - KEYS
    struct keys {
        static var tutorialScreenDisplayed: String { return "ktutorialScreenDisplayed" }
        static var isUserLoggedIn: String { return "kIsUserLoggedIn" }
        static var hasUserSkippedLogin: String { return "kHasUserSkippedLogin" }
        static var hasUserAgreedToTermAndCondition: String { return "kHasUserAgreedToTermAndCondition" }
        static var languageId: String { return "klanguageId" }
        static var applicationLanguageId: String { return "kapplicationLanguageId" }
        static var playingMode: String { return "kplayingMode" }
        static var noOfDailyVerse: String { return "kNoOfDailyVerse" }
        static var readingPlanTargetType: String { return "kReadingPlanTargetType" }
        static var readerLineSpacing: String { return "kreaderLineSpacing" }
        static var screenTimeout: String { return "kscreenTimeout" }
        static var downloadOnlyWifi: String { return "kdownloadOnlyWifi" }
        static var autoMarkAsRead: String { return "kautoMarkAsRead" }
        static var isAutoNightModeDisableProgrametically: String { return "KIsAutoNightModeDisableProgrametically" }
        static var autoNightMode: String { return "kautoNightMode" }
        static var readingPlanReminder: String { return "kreadingPlanReminder" }
        static var reminderTime: String { return "kreminderTime" }
        static var autoNightModeStartTime: String { return "kautoNightModeStartTime" }
        static var autoNightModeEndTime: String { return "kautoNightModeEndTime" }
        static var readingDuration: String { return "kreadingDuration" }
        static var currentTheme: String { return "kcurrentTheme" }
        static var explanations: String { return "kexplanations" }
        static var selectedExplanations: String { return "kselectedExplanations" }
        static var textFontSize: String { return "ktextFontSize" }
        static var applicationDisplaymode: String { return "kapplicationDisplaymode" }
    }
    
    func set(_ value: Any?, forKey: String) {
        UserDefaults.standard.set(value, forKey: forKey)
        UserDefaults.standard.synchronize()
    }
    
    func getValue(forKey: String) -> Any? {
       return UserDefaults.standard.value(forKey: forKey)
    }
}
