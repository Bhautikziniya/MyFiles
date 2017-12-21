//
//  User.swift
//  TaskChat
//
//  Created by Bhautik Ziniya on 9/14/16.
//  Copyright © 2016 Agile Infoways. All rights reserved.
//

import Foundation

class User: NSObject, NSCoding {
    
    // MARK: - Shared Instance
    static let currentUser = User()
    
    //Mark: - Fields
//    var contactNumber : PhoneNumber?
    var id : String?
    var firstName : String?
    var lastName : String?
    var email : String?
    var teamCode : String?
    var profilePhotoUrl : String?
    var profilePhotoName : String?
    var role : String?
    var contactNumber : String?
    var isOwner : String?
    var QBID : String?
    var userProjects : [[String:AnyObject]]?
    var userTeamMembers : [[String:AnyObject]]?
    var isUpdated : Bool?
    var timeZone : String?
    var pushNotification : Bool?
    var emailNotification : Bool?
    
    var QBUserName : String {
        get {
        return "Taskchat" + "" + self.id!
        }
    }
    
    var UserFullName : String {
        get {
            return self.firstName! + " " + self.lastName!
        }
    }
    
    class var isLoggedIn : Bool {
        return UserDefaults.standard.object(forKey: "user") != nil
    }
    
    override init() {
        super.init()
    }
    
    // MARK: - NSCoding
    required init?(coder aDecoder: NSCoder) {
        guard let id = aDecoder.decodeObject(forKey: "id") as? String,
            let firstName = aDecoder.decodeObject(forKey: "firstname") as? String,
            let lastName = aDecoder.decodeObject(forKey: "lastname") as? String,
            let email = aDecoder.decodeObject(forKey: "email") as? String,
            let teamCode = aDecoder.decodeObject(forKey: "teamcode") as? String,
            let profilePhotoUrl = aDecoder.decodeObject(forKey: "profilephotourl") as? String,
            let profilePhotoName = aDecoder.decodeObject(forKey: "profilephotoname") as? String,
            let role = aDecoder.decodeObject(forKey: "role") as? String,
            let contactNumber = aDecoder.decodeObject(forKey: "contactnumber") as? String,
            let isOwner = aDecoder.decodeObject(forKey: "isowner") as? String,
            let QBID = aDecoder.decodeObject(forKey: "quickblox_user_id") as? String,
            let userProjects = aDecoder.decodeObject(forKey: "userProjects") as? [[String:AnyObject]],
            let userTeamMembers = aDecoder.decodeObject(forKey: "userTeamMembers") as? [[String:AnyObject]],
            let isUpdated = aDecoder.decodeObject(forKey: "is_updated") as? Bool,
            let timeZone = aDecoder.decodeObject(forKey: "timezone") as? String,
            let pushNotification = aDecoder.decodeObject(forKey: "pushNotification") as? Bool,
            let emailNotification = aDecoder.decodeObject(forKey: "emailNotification") as? Bool
        
            else { return nil }
        
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.teamCode = teamCode
        self.profilePhotoUrl = profilePhotoUrl
        self.profilePhotoName = profilePhotoName
        self.role = role
        self.contactNumber = contactNumber
        self.isOwner = isOwner
        self.QBID = QBID
        self.userProjects = userProjects
        self.userTeamMembers = userTeamMembers
        self.timeZone = timeZone
        self.isUpdated = isUpdated
        self.pushNotification = pushNotification
        self.emailNotification = emailNotification
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.firstName, forKey: "firstname")
        aCoder.encode(self.lastName, forKey: "lastname")
        aCoder.encode(self.email, forKey: "email")
        aCoder.encode(self.teamCode, forKey: "teamcode")
        aCoder.encode(self.profilePhotoUrl, forKey: "profilephotourl")
        aCoder.encode(self.profilePhotoName, forKey: "profilephotoname")
        aCoder.encode(self.role, forKey: "role")
        aCoder.encode(self.contactNumber, forKey: "contactnumber")
        aCoder.encode(self.isOwner, forKey: "isowner")
        aCoder.encode(self.QBID, forKey: "quickblox_user_id")
        aCoder.encode(self.userProjects, forKey: "userProjects")
        aCoder.encode(self.userTeamMembers, forKey: "userTeamMembers")
        aCoder.encode(self.isUpdated, forKey: "is_updated")
        aCoder.encode(self.timeZone, forKey: "timezone")
        aCoder.encode(self.pushNotification, forKey: "pushNotification")
        aCoder.encode(self.emailNotification, forKey: "emailNotification")
    }
    
    func defaultAssignments() {
        self.id = nil
        self.firstName = nil
        self.lastName = nil
        self.email = nil
        self.teamCode = nil
        self.profilePhotoUrl = nil
        self.profilePhotoName = nil
        self.role = nil
        self.contactNumber = nil
        self.isOwner = nil
        self.QBID = nil
        self.userProjects = nil
        self.userTeamMembers = nil
        self.timeZone = nil
        self.isUpdated = false
        self.pushNotification = nil
        self.emailNotification = nil
    }
    
    // MARK: - Session Functions
    func save() {
        let data = NSKeyedArchiver.archivedData(withRootObject: self)
        UserDefaults.standard.set(data, forKey: "user")
        UserDefaults.standard.synchronize()
    }
    
    
    func loadUser() {
        let objUser = User.loadSavedUser()
        self.copyUser(objUser: objUser)
    }
    
    func copyUser(objUser : User) {
        self.id = objUser.id
        self.firstName = objUser.firstName
        self.lastName = objUser.lastName
        self.email = objUser.email
        self.teamCode = objUser.teamCode
        self.profilePhotoUrl = objUser.profilePhotoUrl
        self.profilePhotoName = objUser.profilePhotoName
        self.role = objUser.role
        self.contactNumber = objUser.contactNumber
        self.isOwner = objUser.isOwner
        self.QBID = objUser.QBID
        self.userProjects = objUser.userProjects
        self.userTeamMembers = objUser.userTeamMembers
        self.isUpdated = objUser.isUpdated
        self.timeZone = objUser.timeZone
        self.pushNotification = objUser.pushNotification
        self.emailNotification = objUser.emailNotification
    }
    
    fileprivate class func loadSavedUser() -> User {
        let data = UserDefaults.standard.object(forKey: "user") as! Data
        return NSKeyedUnarchiver.unarchiveObject(with: data) as! User
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "user")
        UserDefaults.standard.synchronize()
        self.defaultAssignments()
    }
    
    class func addUser(user : User) {
        
        let data = UserDefaults.standard.object(forKey: "pref") as? Data
        var arr : NSMutableArray!
        
        if data != nil {
             arr = NSKeyedUnarchiver.unarchiveObject(with: data!) as? NSMutableArray
            
            if arr != nil {
                arr!.add(user)
            } else {
                arr = NSMutableArray()
                arr!.add(user)
            }
        } else {
            arr = NSMutableArray()
            arr!.add(user)
        }
        
        self.saveUsers(users: arr!)
    }
    
    class func removeUser(user : User) {
        let users = self.getAllUsers()
        
        for (index,userElement) in users!.enumerated() {
            if (userElement as! User).id == user.id {
                users?.removeObject(at: index)
                break
            }
        }
        
        self.saveUsers(users: users!)
    }
    
    class func getAllUsers() -> NSMutableArray? {
        let data = UserDefaults.standard.object(forKey: "pref") as? Data
        if data != nil {
            return NSKeyedUnarchiver.unarchiveObject(with: data!) as? NSMutableArray
        } else {
            return nil
        }
    }
    
    class func getUser(id : String) -> User? {
        let users = self.getAllUsers()
        for (_,userElement) in users!.enumerated() {
            if (userElement as! User).id == id {
                return userElement as? User
            }
        }
        return nil
    }
    
    class func getUser(teamCode : String) -> User? {
        let users = self.getAllUsers()
        for (_,userElement) in users!.enumerated() {
            if (userElement as! User).teamCode == teamCode {
                return userElement as? User
            }
        }
        return nil
    }
    
    fileprivate class func saveUsers(users : NSMutableArray) {
        let data1 = NSKeyedArchiver.archivedData(withRootObject: users)
        UserDefaults.standard.set(data1, forKey: "pref")
        UserDefaults.standard.synchronize()
    }
}
