//
//  AACoreDataManager.swift
//  Alarm App
//
//  Created by Malav Soni on 15/12/16.
//  Copyright © 2016 AgileInfoWays Pvt.Ltd. All rights reserved.
//

import UIKit
import CoreData

typealias blockAppendChatUser = (CRMChat) -> Void
typealias blockUpdateChatCountChatUser = (CRMChat) -> Void
typealias arrOfoffLineChatMessages = ([CRMChat]) -> Void



class CRMCoreDataManager: NSObject
{
    
    var addedNewChatMessage:blockAppendChatUser?
    var updateChatUnreadCount:blockUpdateChatCountChatUser?
    var gotNewMessages:arrOfoffLineChatMessages?
    
    // MARK: - Private Variables And Methods
    // MARK: - Core Data stack
    
    static let DATABASE_NAME:String = "CRM"
    
    
    
    lazy private var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.agile.alarm.Test" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as NSURL
    }()
    lazy private var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: DATABASE_NAME, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    
    lazy private var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("\(DATABASE_NAME).sqlite")
        print("URL :: \(String(describing: url))");
        var failureReason = "There was an error creating or loading the application's saved data."
        do
        {
            let options = [ NSInferMappingModelAutomaticallyOption : true,                            NSMigratePersistentStoresAutomaticallyOption : true]
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        }
        catch
        {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            print(dict)
            
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            //abort()
        }
        return coordinator
    }()
    
    
    
    lazy private var managedObjectContext: NSManagedObjectContext =
        {
            
            let coordinator = self.persistentStoreCoordinator
            var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            managedObjectContext.persistentStoreCoordinator = coordinator
            return managedObjectContext
    }()
    // MARK: - Core Data Saving support
    @available(iOS 10.0, *)
    lazy private var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: DATABASE_NAME)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    private func saveContext ()
    {
        if #available(iOS 10.0, *)
        {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
        else
        {
            // Fallback on earlier versions
            if managedObjectContext.hasChanges
            {
                do
                {
                    try managedObjectContext.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    //NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                    abort()
                }
            }
        }
    }
    
    private func getNewUniqueNotificationId() -> String {
        return String(format: "%.0f", Date().timeIntervalSince1970)
    }
    
    
    func saveCoreDataContext() -> Void
    {
        self.saveContext()
    }
    
    static let shared: CRMCoreDataManager = CRMCoreDataManager()
    
    //    {
    //        return CRMCoreDataManager()
    //    }
    
    //MARK:- Clear Data
    
    public func clearStaticData() -> Void
    {
        self.deleteAllRecods(fromEntityName: "Item_cause")
        self.deleteAllRecods(fromEntityName: "Item_condition")
        self.deleteAllRecods(fromEntityName: "Service_status")
        self.deleteAllRecods(fromEntityName: "ServicesData")
        self.deleteAllRecods(fromEntityName: "Users")
        
        /*
         self.deleteData(entityToFetch: "") { (bool) in
         ////print("Delete data in Item_cause Table")
         }
         self.deleteData(entityToFetch: "") { (bool) in
         ////print("Delete data in Item_condition Table")
         }
         self.deleteData(entityToFetch: "") { (bool) in
         ////print("Delete data in Service_status Table")
         }
         self.deleteData(entityToFetch: "") { (bool) in
         ////print("Delete data in ServicesData Table")
         }
         self.deleteData(entityToFetch: "Users") { (bool) in
         ////print("Delete data in Users Table")
         }
         */
        
    }
    public func clearDatabase() -> Void
    {
        self.deleteAllRecods(fromEntityName: "SeeLog")
        self.deleteAllRecods(fromEntityName: "NotificationList")
        self.deleteAllRecods(fromEntityName: "OrderScheduleTable")
        self.deleteAllRecods(fromEntityName: "OrderStatusTable")
        self.deleteAllRecods(fromEntityName: "InvoiceDetail")
        self.deleteAllRecods(fromEntityName: "Invoice")
        self.deleteAllRecods(fromEntityName: "Log")
        self.deleteAllRecods(fromEntityName: "OrderDetailTable")
       // self.deleteAllRecods(fromEntityName: "Photo")
        self.deleteAllRecods(fromEntityName: "Task")
        self.deleteAllRecods(fromEntityName: "Mettress")
       // self.deleteAllRecods(fromEntityName: "Video")
        self.deleteAllRecods(fromEntityName: "Modules")
        self.deleteAllRecods(fromEntityName: "SubTechnician")
        self.deleteAllRecods(fromEntityName: "Country")
        
        CRMCoreDataManager.shared.deleteAllRecods(fromEntityName: "ChatHistory")
        CRMCoreDataManager.shared.deleteAllRecods(fromEntityName: "ChatUserList")
    }
    
    //MARK:- Preload Data
    
    func preloadContentInCoreDataIfNotExist() -> Void
    {
        if let value:CRMCity = self.getLastCity()
        {
            print(value.cityName)
            
        }
        
        // self.insertDummyDataInV1Migration()
        // //print(self.getUserList())
        ////print("\(self.parseWorkoutCSV())");
        //        self.preLoadStateInCoreDataInNotExist()
        //        self.preLoadCityInCoreDataInNotExist()
        //        self.preLoadZipInCoreDataInNotExist()
        
    }
    func saveStaticData(withDetails object:NSDictionary) -> Void
    {
        if let value = object.value(forKey: "item_cause") as? [[String : Any]]
        {
            
            self.preLoadItemCauseInCoreDataInNotExist(withData: value)
        }
        if let value = object.value(forKey: "city") as? [[String : Any]]
        {
            self.preLoadCityInCoreDataInNotExist(withData: value)
        }
        if let value = object.value(forKey: "zipcode") as? [[String : Any]]
        {
            self.preLoadZipCodeCoreDataInNotExist(withData: value)
        }
        if let value = object.value(forKey: "state") as? [[String : Any]]
        {
            self.preLoadStateInCoreDataInNotExist(withData:value)
        }
        if let value = object.value(forKey: "reason_cause") as? [[String : Any]]
        {
            
            self.preLoadSubItemCauseInCoreDataInNotExist(withData:value)
        }
        if let value = object.value(forKey: "reschedule_reasons") as? [[String : Any]]
        {
            
            self.preLoadRescheduleReasonInCoreDataInNotExist(withData:value)
        }
        if let value = object.value(forKey: "late_reasons") as? [[String : Any]]
        {
            
            self.preLoadLateReasonInCoreDataInNotExist(withData:value)
        }
        
        if let value = object.value(forKey: "item_condition") as? [[String : Any]]
        {
            
            self.preLoadItemConditionInCoreDataInNotExist(withData: value)
        }
        if let value = object.value(forKey: "service_status") as? [[String : Any]]
        {
            
            self.preLoadServiceStatusInCoreDataInNotExist(withData: value)
        }
        if let value = object.value(forKey: "services") as? [[String : Any]]
        {
            
            self.preLoadServicesDataInCoreDataInNotExist(withData: value)
        }
        if let value = object.value(forKey: "users") as? [[String : Any]]
        {
            self.preLoadUsersInCoreDataInNotExist(withData: value)
        }
        if let value = object.value(forKey: "modules") as? [[String : Any]]
        {
           
            self.preLoadModulesInCoreDataInNotExist(withData: value)
        }
        
        //print(self.getSubItemCauseList(withCauseId: ""));
        print(self.getRescheduleReasonList())
        
        
    }
    
    private func preLoadStateInCoreDataInNotExist() -> Void {
        if let fetchRequest = self.managedObjectModel.fetchRequestTemplate(forName: "stateNameFetchRequest")
        {
            do {
                if let fetchedState = try self.managedObjectContext.fetch(fetchRequest) as? [State]
                {
                    if fetchedState.count == 0
                    {
                        var aryState = self.parseStateCSV()
                        
                        // Removing First Row as it is names of coloum
                        aryState.removeFirst()
                        
                        for index in 0..<aryState.count{
                            
                            // Create Entity
                            if let entity = NSEntityDescription.entity(forEntityName: "State", in: self.managedObjectContext){
                                // Initialize Record
                                let stateObject = State(entity: entity, insertInto: self.managedObjectContext)
                                //////print(stateObject)
                                
                                stateObject.state_name = aryState[index].stateName
                                stateObject.state_code = aryState[index].stateCode
                                if let intStatus = Int.init(aryState[index].status){
                                    stateObject.status = Bool.init(NSNumber.init(value: intStatus))
                                }
                                if let state_id = Int64.init(aryState[index].stateId){
                                    stateObject.state_id = state_id
                                }
                                stateObject.created = aryState[index].created
                                stateObject.modified = aryState[index].modified
                                
                                
                                do{
                                    try stateObject.managedObjectContext?.save()
                                }catch{
                                    ////print("Failed to save state object :: At Index = \(index)")
                                }
                            }else{
                                ////print("Failed to create entity :: At Index = \(index)")
                            }
                        }
                    }else{
                        ////print("state already loaded")
                    }
                }
            }catch{
                
            }
        }
    }
    private func preLoadZipInCoreDataInNotExist() -> Void
    {
        if let fetchRequest = self.managedObjectModel.fetchRequestTemplate(forName: "ZipNameFetchRequest")
        {
            do {
                if let fetchedZip = try self.managedObjectContext.fetch(fetchRequest) as? [Zip]
                {
                    if fetchedZip.count == 0
                    {
                        var aryZip = self.parseZipCSV()
                        
                        // Removing First Row as it is names of coloum
                        aryZip.removeFirst()
                        
                        for index in 0..<aryZip.count
                        {
                            
                            // Create Entity
                            if let entity = NSEntityDescription.entity(forEntityName: "Zip", in: self.managedObjectContext){
                                // Initialize Record
                                let zipObject = Zip(entity: entity, insertInto: self.managedObjectContext)
                                
                                if let intCityId = Int64.init(aryZip[index].cityId)
                                {
                                    zipObject.city_id = intCityId
                                    
                                }
                                if let intCountryId = Int64.init(aryZip[index].countryId)
                                {
                                    zipObject.county_id = intCountryId
                                }
                                if let intStateId = Int64.init(aryZip[index].stateId)
                                {
                                    zipObject.state_id = intStateId
                                }
                                if let intStatus = Int64.init(aryZip[index].status)
                                {
                                    zipObject.status = intStatus
                                }
                                if let intZipId = Int64.init(aryZip[index].zipId)
                                {
                                    zipObject.zip_id = intZipId
                                }
                                if let intZipCode = Int64.init(aryZip[index].zipCode)
                                {
                                    
                                    zipObject.zipcode = intZipCode
                                }
                                zipObject.created = aryZip[index].created
                                zipObject.modified = aryZip[index].modified
                                
                                
                                do{
                                    try zipObject.managedObjectContext?.save()
                                }catch{
                                    ////print("Failed to save state object :: At Index = \(index)")
                                }
                            }else{
                                ////print("Failed to create entity :: At Index = \(index)")
                            }
                        }
                    }else{
                        ////print("Zip already loaded")
                    }
                }
            }catch{
                
            }
        }
    }
    
    private func preLoadCityInCoreDataInNotExist() -> Void
    {
        if let fetchRequest = self.managedObjectModel.fetchRequestTemplate(forName: "CityNameFetchRequest")
        {
            do {
                if let fetchedCity = try self.managedObjectContext.fetch(fetchRequest) as? [City]{
                    if fetchedCity.count == 0{
                        var aryCity = self.parseCityCSV()
                        
                        // Removing First Row as it is names of coloum
                        aryCity.removeFirst()
                        
                        for index in 0..<aryCity.count{
                            
                            // Create Entity
                            if let entity = NSEntityDescription.entity(forEntityName: "City", in: self.managedObjectContext){
                                // Initialize Record
                                let cityObject = City(entity: entity, insertInto: self.managedObjectContext)
                                if let city_id = Int64.init(aryCity[index].cityId){
                                    cityObject.city_id = city_id
                                }
                                if let state_id = Int64.init(aryCity[index].stateId){
                                    cityObject.state_id = state_id
                                }
                                if let intStatus = Int.init(aryCity[index].status){
                                    cityObject.status = Bool.init(NSNumber.init(value: intStatus))
                                }
                                if let area_code = Int64.init(aryCity[index].areaCode){
                                    cityObject.area_code = area_code
                                }
                                cityObject.city_name = aryCity[index].cityName
                                cityObject.created = aryCity[index].created
                                cityObject.modified = aryCity[index].modified
                                
                                
                                do{
                                    try cityObject.managedObjectContext?.save()
                                }catch{
                                    ////print("Failed to save city object :: At Index = \(index)")
                                }
                            }else{
                                ////print("Failed to create entity :: At Index = \(index)")
                            }
                        }
                    }else{
                        ////print("City already loaded")
                    }
                }
            }catch{
                
            }
        }
    }
    private func preLoadItemCauseInCoreDataInNotExist(withData aryItemCause:[[String:Any]]) -> Void
    {
        self.deleteAllRecods(fromEntityName: "Item_cause")
        
        let itemCauseFetch = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Item_cause")
        do {
            if let fetchedItemCause = try self.managedObjectContext.fetch(itemCauseFetch) as? [Item_cause]
            {
                if fetchedItemCause.count == 0
                {
                    for index in 0..<aryItemCause.count
                    {
                        // Create Entity
                        if let entity = NSEntityDescription.entity(forEntityName: "Item_cause", in: self.managedObjectContext)
                        {
                            // Initialize Record
                            let record:[String:Any] = aryItemCause[index];
                            let ItemCauseObject = Item_cause(entity:entity , insertInto:self.managedObjectContext) as Item_cause
                            if let id = record["id"] as?  String
                            {
                                if let intId = Int16(id){
                                    ItemCauseObject.id = intId
                                }
                            }
                            if let status = record["status"] as? String
                            {
                                if let intStatus = Int16(status)
                                {
                                    ItemCauseObject.status = intStatus
                                }
                                
                            }
                            if let created = record["created"] as? String
                            {
                                ItemCauseObject.created = created
                            }
                            if let modified = record["modified"] as? String
                            {
                                ItemCauseObject.modified = modified
                            }
                            if let title = record["title"] as? String
                            {
                                ItemCauseObject.title = title
                            }
                            do{
                                try ItemCauseObject.managedObjectContext?.save()
                            }catch{
                                ////print("Failed to save city object :: At Index = \(index)")
                            }
                        }else{
                            ////print("Failed to create entity :: At Index = \(index)")
                        }
                    }
                }
                else
                {
                    ////print("ItemCause already loaded")
                }
            }
        }catch{
            
        }
    }
    private func preLoadSubItemCauseInCoreDataInNotExist(withData arySubItemCause:[[String:Any]]) -> Void
    {
        self.deleteAllRecods(fromEntityName: "SubItemCause")
        if let entity = NSEntityDescription.entity(forEntityName: "SubItemCause", in: self.managedObjectContext)
        {
            for index in 0..<arySubItemCause.count
            {
                // Create Entity
                let record:[String:Any] = arySubItemCause[index]
                let id:String = (record["id"] as? String)!
                if self.checkSubItemCauseAvailableInCoreData(fromId: id) == false
                {
                    
                    // Initialize Record
                    
                    let SubItemCauseObject = SubItemCause(entity:entity , insertInto:self.managedObjectContext) as SubItemCause
                    if let id = record["id"] as?  String
                    {
                        if let intId = Int64(id){
                            SubItemCauseObject.id = intId
                        }
                    }
                    if let status = record["status"] as? String
                    {
                        if let intStatus = Int64(status)
                        {
                            SubItemCauseObject.status = intStatus
                        }
                        
                    }
                    if let status = record["cause"] as? String
                    {
                        if let intStatus = Int64(status)
                        {
                            SubItemCauseObject.cause = intStatus
                        }
                        
                    }
                    if let created = record["created"] as? String
                    {
                        SubItemCauseObject.created = created
                    }
                    if let modified = record["modified"] as? String
                    {
                        SubItemCauseObject.modified = modified
                    }
                    if let title = record["reason"] as? String
                    {
                        SubItemCauseObject.reason = title
                    }
                    do{
                        try SubItemCauseObject.managedObjectContext?.save()
                    }catch{
                        ////print("Failed to save city object :: At Index = \(index)")
                    }
                }else{
                    ////print("Failed to create entity :: At Index = \(index)")
                }
            }
        }
    }
    
    private func preLoadRescheduleReasonInCoreDataInNotExist(withData aryRescheduleReason:[[String:Any]]) -> Void
    {
        self.deleteAllRecods(fromEntityName: "RescheduleReasons")
        if let entity = NSEntityDescription.entity(forEntityName: "RescheduleReasons", in: self.managedObjectContext)
        {
            for index in 0..<aryRescheduleReason.count
            {
                // Create Entity
                let record:[String:Any] = aryRescheduleReason[index]
                let id:String = (record["id"] as? String)!
                if self.checkRescheduleReasonAvailableInCoreData(fromId: id) == false
                {
                    
                    // Initialize Record
                    
                    let reschedulReasonObject = RescheduleReasons(entity:entity , insertInto:self.managedObjectContext) as RescheduleReasons
                    if let value  = record["id"] as? Int
                    {
                        reschedulReasonObject.id = Int64(value)
                    }
                    else if let value  = record["id"] as? String
                    {
                        reschedulReasonObject.id = Int64(value)!
                    }
                    
                    if let value = record["reason"] as? String
                    {
                        reschedulReasonObject.reason = value
                    }
                    if let created = record["created"] as? String
                    {
                        reschedulReasonObject.created = created
                    }
                    if let modified = record["modified"] as? String
                    {
                        reschedulReasonObject.modified = modified
                    }
                    if let value = record["status"] as? Int
                    {
                        reschedulReasonObject.status = Int64(value)
                    }
                    do{
                        try reschedulReasonObject.managedObjectContext?.save()
                    }catch{
                        ////print("Failed to save city object :: At Index = \(index)")
                    }
                }else{
                    ////print("Failed to create entity :: At Index = \(index)")
                }
                
            }
        }
        
        
        
    }
    private func preLoadLateReasonInCoreDataInNotExist(withData aryRescheduleReason:[[String:Any]]) -> Void
    {
        self.deleteAllRecods(fromEntityName: "LateScheduleReason")
        
        if let entity = NSEntityDescription.entity(forEntityName: "LateScheduleReason", in: self.managedObjectContext)
        {
            for index in 0..<aryRescheduleReason.count
            {
                // Create Entity
                let record:[String:Any] = aryRescheduleReason[index]
                let id:String = (record["id"] as? String)!
                if self.checkLateReasonAvailableInCoreData(fromId:id) == false
                {
                    
                    // Initialize Record
                    
                    let reschedulReasonObject = LateScheduleReason(entity:entity , insertInto:self.managedObjectContext) as LateScheduleReason
                    if let value  = record["id"] as? Int
                    {
                        reschedulReasonObject.id = Int64(value)
                    }
                    else if let value  = record["id"] as? String
                    {
                        reschedulReasonObject.id = Int64(value)!
                    }
                    
                    if let value = record["reason"] as? String
                    {
                        reschedulReasonObject.reason = value
                    }
                    if let created = record["created"] as? String
                    {
                        reschedulReasonObject.created = created
                    }
                    if let modified = record["modified"] as? String
                    {
                        reschedulReasonObject.modified = modified
                    }
                    if let value = record["status"] as? Int
                    {
                        reschedulReasonObject.status = Int64(value)
                    }
                    do{
                        try reschedulReasonObject.managedObjectContext?.save()
                    }catch{
                        ////print("Failed to save city object :: At Index = \(index)")
                    }
                }else{
                    ////print("Failed to create entity :: At Index = \(index)")
                }
                
            }
        }
        
    }
    
    private func preLoadCityInCoreDataInNotExist(withData aryItemCause:[[String:Any]]) -> Void
    {
        let itemCauseFetch = NSFetchRequest<NSFetchRequestResult>.init(entityName: "City")
        do {
            if let fetchedItemCause = try self.managedObjectContext.fetch(itemCauseFetch) as? [City]
            {
                for index in 0..<aryItemCause.count
                {
                    // Create Entity
                    if let entity = NSEntityDescription.entity(forEntityName: "City", in: self.managedObjectContext)
                    {
                        // Initialize Record
                        let record:[String:Any] = aryItemCause[index];
                        let ItemCauseObject = City(entity:entity , insertInto:self.managedObjectContext) as City
                        if let id = record["area_code"] as?  String
                        {
                            if let intId = Int64(id){
                                ItemCauseObject.area_code = intId
                            }
                        }
                        if let id = record["city_id"] as?  String
                        {
                            if let intId = Int64(id){
                                ItemCauseObject.city_id = intId
                            }
                        }
                        if let id = record["state_id"] as?  String
                        {
                            if let intId = Int64(id){
                                ItemCauseObject.state_id = intId
                            }
                        }
                        if let id = record["status"] as?  String
                        {
                            if let intId = Int(id)
                            {
                                if intId == 0
                                {
                                    ItemCauseObject.status = false
                                }
                                else
                                {
                                    ItemCauseObject.status = true
                                }
                                
                            }
                        }
                        
                        if let created = record["created"] as? String
                        {
                            ItemCauseObject.created = created
                        }
                        if let modified = record["modified"] as? String
                        {
                            ItemCauseObject.modified = modified
                        }
                        if let title = record["city_name"] as? String
                        {
                            ItemCauseObject.city_name = title
                        }
                        do{
                            try ItemCauseObject.managedObjectContext?.save()
                        }catch{
                            ////print("Failed to save city object :: At Index = \(index)")
                        }
                    }else{
                        ////print("Failed to create entity :: At Index = \(index)")
                    }
                }
            }
        }catch{
            
        }
    }
    private func preLoadStateInCoreDataInNotExist(withData aryItemCause:[[String:Any]]) -> Void
    {
        let itemCauseFetch = NSFetchRequest<NSFetchRequestResult>.init(entityName: "State")
        do {
            if let fetchedItemCause = try self.managedObjectContext.fetch(itemCauseFetch) as? [State]
            {
                for index in 0..<aryItemCause.count
                {
                    // Create Entity
                    if let entity = NSEntityDescription.entity(forEntityName: "State", in: self.managedObjectContext)
                    {
                        // Initialize Record
                        let record:[String:Any] = aryItemCause[index];
                        let ItemCauseObject = State(entity:entity , insertInto:self.managedObjectContext) as State
                        
                        if let id = record["state_id"] as?  String
                        {
                            if let intId = Int64(id){
                                ItemCauseObject.state_id = intId
                            }
                        }
                        if let id = record["state_code"] as?  String
                        {
                            ItemCauseObject.state_code = id
                        }
                        if let id = record["status"] as?  String
                        {
                            if let intId = Int(id)
                            {
                                if intId == 0
                                {
                                    ItemCauseObject.status = false
                                }
                                else
                                {
                                    ItemCauseObject.status = true
                                }
                                
                            }
                        }
                        
                        if let created = record["created"] as? String
                        {
                            ItemCauseObject.created = created
                        }
                        if let modified = record["modified"] as? String
                        {
                            ItemCauseObject.modified = modified
                        }
                        if let title = record["state_name"] as? String
                        {
                            ItemCauseObject.state_name = title
                        }
                        do{
                            try ItemCauseObject.managedObjectContext?.save()
                        }catch{
                            ////print("Failed to save city object :: At Index = \(index)")
                        }
                    }else{
                        ////print("Failed to create entity :: At Index = \(index)")
                    }
                }
            }
        }catch{
            
        }
    }
    private func preLoadZipCodeCoreDataInNotExist(withData aryItemCause:[[String:Any]]) -> Void
    {
        let itemCauseFetch = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Zip")
        do {
            if let fetchedItemCause = try self.managedObjectContext.fetch(itemCauseFetch) as? [Zip]
            {
                for index in 0..<aryItemCause.count
                {
                    // Create Entity
                    if let entity = NSEntityDescription.entity(forEntityName: "Zip", in: self.managedObjectContext)
                    {
                        // Initialize Record
                        let record:[String:Any] = aryItemCause[index];
                        let ItemCauseObject = Zip(entity:entity , insertInto:self.managedObjectContext) as Zip
                        if let id = record["city_id"] as?  String
                        {
                            if let intId = Int64(id){
                                ItemCauseObject.city_id = intId
                            }
                        }
                        if let id = record["county_id"] as?  String
                        {
                            if let intId = Int64(id){
                                ItemCauseObject.county_id = intId
                            }
                        }
                        if let id = record["state_id"] as?  String
                        {
                            if let intId = Int64(id){
                                ItemCauseObject.state_id = intId
                            }
                        }
                        if let id = record["status"] as?  String
                        {
                            if let intId = Int64(id){
                                ItemCauseObject.status = intId
                            }
                        }
                        if let id = record["zip_id"] as?  String
                        {
                            if let intId = Int64(id){
                                ItemCauseObject.zip_id = intId
                            }
                        }
                        
                        if let created = record["created"] as? String
                        {
                            ItemCauseObject.created = created
                        }
                        if let modified = record["modified"] as? String
                        {
                            ItemCauseObject.modified = modified
                        }
                        if let title = record["zipcode"] as? String
                        {
                            if let intId = Int64(title)
                            {
                                ItemCauseObject.zipcode = intId
                            }
                        }
                        
                        do{
                            try ItemCauseObject.managedObjectContext?.save()
                        }catch{
                            ////print("Failed to save city object :: At Index = \(index)")
                        }
                    }else{
                        ////print("Failed to create entity :: At Index = \(index)")
                    }
                }
            }
        }catch{
            
        }
    }
    
    private func preLoadModulesInCoreDataInNotExist(withData aryModules:[[String:Any]]) -> Void
    {
        
        self.deleteAllRecods(fromEntityName: "Modules")
        
        let modulesFetch = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Modules")
        do {
            if let fetchedItemCause = try self.managedObjectContext.fetch(modulesFetch) as? [Modules]
            {
                if fetchedItemCause.count == 0
                {
                    for index in 0..<aryModules.count
                    {
                        // Create Entity
                        if let entity = NSEntityDescription.entity(forEntityName: "Modules", in: self.managedObjectContext)
                        {
                            // Initialize Record
                            let record:[String:Any] = aryModules[index];
                            let ModuleObject = Modules(entity:entity , insertInto:self.managedObjectContext) as Modules
                            if let id = record["id"] as?  String
                            {
                                ModuleObject.module_id = id
                            }
                            if let moduleName = record["module_name"] as? String
                            {
                                ModuleObject.module_name = moduleName
                                
                            }
                            if let type = record["module_type"] as? String
                            {
                                ModuleObject.module_type = type
                                
                            }
                            do{
                                try ModuleObject.managedObjectContext?.save()
                            }catch{
                                ////print("Failed to save city object :: At Index = \(index)")
                            }
                        }else{
                            ////print("Failed to create entity :: At Index = \(index)")
                        }
                    }
                }
                else
                {
                    ////print("ItemCause already loaded")
                }
            }
        }catch{
            
        }
    }
    
    private func preLoadItemConditionInCoreDataInNotExist(withData aryItemCondition:[[String:Any]]) -> Void
    {
        self.deleteAllRecods(fromEntityName: "Item_condition")
        
        let itemConditionFetch = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Item_condition")
        do {
            if let fetchedItemCause = try self.managedObjectContext.fetch(itemConditionFetch) as? [Item_condition]
            {
                if fetchedItemCause.count == 0
                {
                    for index in 0..<aryItemCondition.count
                    {
                        // Create Entity
                        if let entity = NSEntityDescription.entity(forEntityName: "Item_condition", in: self.managedObjectContext)
                        {
                            // Initialize Record
                            let record:[String:Any] = aryItemCondition[index];
                            let ItemConditionObject = Item_condition(entity:entity , insertInto:self.managedObjectContext) as Item_condition
                            
                            if let id = record["id"] as? String
                            {
                                if let intId = Int64(id)
                                {
                                    ItemConditionObject.id = intId
                                }
                                
                            }
                            if let status = record["status"] as? String
                            {
                                if let intStatus = Int64(status)
                                {
                                    ItemConditionObject.status = intStatus
                                }
                            }
                            if let created = record["created"] as? String
                            {
                                ItemConditionObject.created = created
                            }
                            if let modified = record["modified"] as? String
                            {
                                ItemConditionObject.modified = modified
                            }
                            if let title = record["title"] as? String
                            {
                                ItemConditionObject.title = title
                            }
                            do{
                                try ItemConditionObject.managedObjectContext?.save()
                            }catch{
                                ////print("Failed to save city object :: At Index = \(index)")
                            }
                        }else{
                            ////print("Failed to create entity :: At Index = \(index)")
                        }
                    }
                }
                else
                {
                    ////print("ItemCause already loaded")
                }
            }
        }catch{
            
        }
    }
    private func preLoadServiceStatusInCoreDataInNotExist(withData aryServiceStatus:[[String:Any]]) -> Void
    {
        self.deleteAllRecods(fromEntityName: "Service_status")
        let serviceStatusFetch = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Service_status")
        do {
            if let fetchedItemCause = try self.managedObjectContext.fetch(serviceStatusFetch) as? [Service_status]
            {
                if fetchedItemCause.count == 0
                {
                    for index in 0..<aryServiceStatus.count
                    {
                        // Create Entity
                        if let entity = NSEntityDescription.entity(forEntityName: "Service_status", in: self.managedObjectContext)
                        {
                            // Initialize Record
                            let record:[String:Any] = aryServiceStatus[index];
                            let ServiceStatusObject = Service_status(entity:entity , insertInto:self.managedObjectContext) as Service_status
                            
                            if let id = record["id"] as? String
                            {
                                if let intId = Int64(id){
                                    ServiceStatusObject.id = intId
                                }
                            }
                            if let status = record["status"] as? String
                            {
                                if let intStatus = Int64(status)
                                {
                                    ServiceStatusObject.status = intStatus
                                }
                            }
                            if let created = record["created"] as? String
                            {
                                ServiceStatusObject.created = created
                            }
                            if let modified = record["modified"] as? String
                            {
                                ServiceStatusObject.modified = modified
                            }
                            if let statusName = record["status_name"] as? String
                            {
                                ServiceStatusObject.status_name = statusName
                            }
                            if let companyId = record["company_id"] as? String
                            {
                                if let intCompanyId = Int64(companyId)
                                {
                                    ServiceStatusObject.company_id = intCompanyId
                                }
                            }
                            do
                            {
                                try ServiceStatusObject.managedObjectContext?.save()
                            }catch
                            {
                                ////print("Failed to save city object :: At Index = \(index)")
                            }
                        }else{
                            ////print("Failed to create entity :: At Index = \(index)")
                        }
                    }
                }
                else
                {
                    ////print("ServiceStatus already loaded")
                }
            }
        }catch{
            
        }
    }
    private func preLoadServicesDataInCoreDataInNotExist(withData aryServices:[[String:Any]]) -> Void
    {
        self.deleteAllRecods(fromEntityName: "Service_status")
        
        let servicesDataFetch = NSFetchRequest<NSFetchRequestResult>.init(entityName: "ServicesData")
        do {
            if let fetchedItemCause = try self.managedObjectContext.fetch(servicesDataFetch) as? [ServicesData]
            {
                if fetchedItemCause.count == 0
                {
                    for index in 0..<aryServices.count
                    {
                        // Create Entity
                        if let entity = NSEntityDescription.entity(forEntityName: "ServicesData", in: self.managedObjectContext)
                        {
                            // Initialize Record
                            let record:[String:Any] = aryServices[index];
                            let ServicesDataObject = ServicesData(entity:entity , insertInto:self.managedObjectContext) as ServicesData
                            
                            if let id = record["id"] as? String
                            {
                                if let intId = Int64(id)
                                {
                                    ServicesDataObject.id = intId
                                }
                                
                            }
                            if let status = record["status"] as? String
                            {
                                if let intStatus = Int64(status)
                                {
                                    ServicesDataObject.status = intStatus
                                }
                                
                            }
                            if let created = record["created"] as? String
                            {
                                ServicesDataObject.created = created
                            }
                            if let modified = record["modified"] as? String
                            {
                                ServicesDataObject.modified = modified
                            }
                            if let serviceName = record["service_name"] as? String
                            {
                                ServicesDataObject.service_name = serviceName
                            }
                            if let companyId = record["company_id"] as? String
                            {
                                if let intCompanyId = Int64(companyId)
                                {
                                    ServicesDataObject.company_id = intCompanyId
                                }
                                
                            }
                            do{
                                try ServicesDataObject.managedObjectContext?.save()
                            }catch{
                                ////print("Failed to save city object :: At Index = \(index)")
                            }
                        }else{
                            ////print("Failed to create entity :: At Index = \(index)")
                        }
                    }
                }
                else
                {
                    ////print("Services already loaded")
                }
            }
        }catch{
            
        }
    }
    
    private func preLoadUsersInCoreDataInNotExist(withData aryUsers:[[String:Any]]) -> Void
    {
        let usersFetch = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Users")
        do {
            if let fetchedUsers = try self.managedObjectContext.fetch(usersFetch) as? [Users]
            {
                if fetchedUsers.count == 0
                {
                    for index in 0..<aryUsers.count
                    {
                        // Create Entity
                        if let entity = NSEntityDescription.entity(forEntityName: "Users", in: self.managedObjectContext)
                        {
                            // Initialize Record
                            let record:[String:Any] = aryUsers[index];
                            let UsersObject = Users(entity:entity , insertInto:self.managedObjectContext) as Users
                            
                            if let id = record["created"] as? String
                            {
                                UsersObject.created = id
                            }
                            if let status = record["fname"] as? String
                            {
                                UsersObject.fname = status
                            }
                            if let created = record["lname"] as? String
                            {
                                UsersObject.lname = created
                            }
                            if let modified = record["user_id"] as? String
                            {
                                UsersObject.user_id = modified
                            }
                            
                            do{
                                try UsersObject.managedObjectContext?.save()
                            }catch{
                                ////print("Failed to save city object :: At Index = \(index)")
                            }
                        }else{
                            ////print("Failed to create entity :: At Index = \(index)")
                        }
                    }
                }
                else
                {
                    ////print("User already loaded")
                }
            }
        }catch{
            
        }
    }
    
    //MARK:- Insert
    
    
    func insertSubTechnicianData(withArray arySubTechnician:[[String:Any]]) -> Void
    {
        for index in 0..<arySubTechnician.count
        {
            // Create Entity
            if let entity = NSEntityDescription.entity(forEntityName: "SubTechnician", in: self.managedObjectContext)
            {
                // Initialize Record
                let record:[String:Any] = arySubTechnician[index];
                if let value = record["user_id"] as? String
                {
                    if self.checkSubTechnicianExistInCoreData(fromUserId: value)
                    {
                        let SubTechnicianObject = SubTechnician(entity:entity , insertInto:self.managedObjectContext) as SubTechnician
                        
                        if let address1 = record["address1"] as? String
                        {
                            SubTechnicianObject.address1 = address1
                        }
                        if let address2 = record["address2"] as? String
                        {
                            SubTechnicianObject.address2 = address2
                        }
                        if let city = record["city"] as? String
                        {
                            SubTechnicianObject.city = city
                        }
                        
                        if let companyCode = record["company_code"] as? String
                        {
                            SubTechnicianObject.company_code = companyCode
                        }
                        
                        if let companyId = record["company_id"] as? String
                        {
                            SubTechnicianObject.company_id = companyId
                        }
                        
                        if let emailId = record["email"] as? String
                        {
                            SubTechnicianObject.email = emailId
                        }
                        
                        if let fax = record["fax"] as? String
                        {
                            SubTechnicianObject.fax = fax
                        }
                        
                        if let firstName = record["fname"] as? String
                        {
                            SubTechnicianObject.fname = firstName
                        }
                        
                        if let lastName = record["lname"] as? String
                        {
                            SubTechnicianObject.lname = lastName
                        }
                        
                        if let loginUserId = record["login_user_id"] as? String
                        {
                            SubTechnicianObject.login_user_id = loginUserId
                        }
                        
                        if let mobileNumber = record["mobile"] as? String
                        {
                            SubTechnicianObject.mobile = mobileNumber
                        }
                        
                        if let modulePermision = record["module_permission"] as? String
                        {
                            SubTechnicianObject.module_permission = modulePermision
                        }
                        
                        if let phoneNumber = record["phonenumber"] as? String
                        {
                            SubTechnicianObject.phonenumber = phoneNumber
                        }
                        
                        if let state = record["state"] as? String
                        {
                            SubTechnicianObject.state = state
                        }
                        
                        if let status = record["status"] as? String
                        {
                            SubTechnicianObject.status = Int16(status)!
                        }
                        if let userId = record["user_id"] as? String
                        {
                            SubTechnicianObject.user_id = userId
                        }
                        if let UserImage = record["user_image"] as? String
                        {
                            SubTechnicianObject.user_image = UserImage
                        }
                        if let userType = record["user_type"] as? String
                        {
                            SubTechnicianObject.user_type = userType
                        }
                        if let zipCode = record["zipcode"] as? String
                        {
                            SubTechnicianObject.zipcode = zipCode
                        }
                        
                        do{
                            try SubTechnicianObject.managedObjectContext?.save()
                        }catch{
                            ////print("Failed to save city object :: At Index = \(index)")
                        }
                    }
                    else
                    {
                        ////Update the sub technician data
                        ////print(record);
                        let objSubTechnician:CRMSubTechnician = CRMSubTechnician.init(withContent: record as NSDictionary)
                        self.updateSubTechnicianDetails(withSubTechnician: objSubTechnician, withIsModifyStatus: false, withModifyDate: Date(),withAddLog: false)
                        
                        ////print("SubTechnician already exist :: At Index = \(index)")
                    }
                }
                
            }else{
                ////print("Failed to create entity :: At Index = \(index)")
            }
        }
        
        
    }
    func insertOrderData(withArray aryOrder:[[String:Any]]) -> Void
    {
        for index in 0..<aryOrder.count
        {
            // Create Entity
            if let entity = NSEntityDescription.entity(forEntityName: "OrderDetailTable", in: self.managedObjectContext)
            {
                // Initialize Record
                let record:[String:Any] = aryOrder[index];
                if let value = record["o_id"] as? String
                {
                    let responseCheckRecord = self.checkOrderDetailTableExistInCoreData(fromOId: value)
                    if responseCheckRecord.isRecordAvailable == false
                    {
                        let OrderDetailObject = OrderDetailTable(entity:entity , insertInto:self.managedObjectContext) as OrderDetailTable
                        
                        if let address1 = record["address1"] as? String
                        {
                            OrderDetailObject.address1 = address1
                        }
                        if let address2 = record["address2"] as? String
                        {
                            OrderDetailObject.address2 = address2
                        }
                        if let additionalInfo = record["additional_info"] as? String
                        {
                            OrderDetailObject.address2 = additionalInfo
                        }
                        if let address2 = record["allotted_hours"] as? String
                        {
                            OrderDetailObject.allotted_hours = address2
                        }
                        if let mergeCompanyId = record["merge_company_id"] as? String
                        {
                            OrderDetailObject.allotted_hours = mergeCompanyId
                        }
                        if let apntmentDate = record["apntmnt_date"] as? String
                        {
                            OrderDetailObject.apntmnt_date = apntmentDate
                        }
                        
                        if let companyCode = record["apntmnt_direction"] as? String
                        {
                            OrderDetailObject.apntmnt_direction = companyCode
                        }
                        
                        if let userType = record["work_phone"] as? String
                        {
                            OrderDetailObject.work_phone = userType
                        }
                        
                        if let companyId = record["apntmnt_time"] as? String
                        {
                            OrderDetailObject.apntmnt_time = companyId
                        }
                        
                        if let emailId = record["city"] as? String
                        {
                            OrderDetailObject.city = emailId
                        }
                        
                        if let fax = record["city_id"] as? String
                        {
                            OrderDetailObject.city_id = fax
                        }
                        if let isAck = record["is_ack"] as? String
                        {
                            OrderDetailObject.is_ack = isAck
                        }
                        if let technician = record["technician"] as? String
                        {
                            OrderDetailObject.technician = technician
                        }
                        
                        if let firstName = record["client_order_no"] as? String
                        {
                            OrderDetailObject.client_order_no = firstName
                        }
                        
                        if let lastName = record["email"] as? String
                        {
                            OrderDetailObject.email = lastName
                        }
                        
                        if let loginUserId = record["first_name"] as? String
                        {
                            OrderDetailObject.first_name = loginUserId
                        }
                        
                        if let mobileNumber = record["home_phone"] as? String
                        {
                            OrderDetailObject.home_phone = mobileNumber
                        }
                        
                        if let modulePermision = record["is_close"] as? String
                        {
                            OrderDetailObject.is_close = modulePermision
                        }
                        
                        if let phoneNumber = record["is_schedule"] as? String
                        {
                            OrderDetailObject.is_schedule = phoneNumber
                        }
                        
                        if let state = record["is_sub_close"] as? String
                        {
                            OrderDetailObject.is_sub_close = state
                        }
                        
                        if let status = record["last_name"] as? String
                        {
                            OrderDetailObject.last_name = status
                        }
                        if let userId = record["lat"] as? String
                        {
                            OrderDetailObject.lat = userId
                        }
                        if let UserImage = record["lng"] as? String
                        {
                            OrderDetailObject.lng = UserImage
                        }
                        if let userType = record["mobile"] as? String
                        {
                            OrderDetailObject.mobile = userType
                        }
                        if let zipCode = record["o_id"] as? String
                        {
                            OrderDetailObject.o_id = zipCode
                        }
                        if let zipCode = record["open_date"] as? String
                        {
                            OrderDetailObject.open_date = zipCode
                        }
                        if let zipCode = record["order_id"] as? String
                        {
                            OrderDetailObject.order_id = zipCode
                        }
                        if let zipCode = record["order_status"] as? String
                        {
                            OrderDetailObject.order_status = zipCode
                        }
                        if let zipCode = record["service_instrcn"] as? String
                        {
                            OrderDetailObject.service_instrcn = zipCode
                        }
                        if let zipCode = record["service_name"] as? String
                        {
                            OrderDetailObject.service_name = zipCode
                        }
                        if let zipCode = record["service_status"] as? String
                        {
                            OrderDetailObject.service_status = zipCode
                        }
                        if let zipCode = record["state"] as? String
                        {
                            OrderDetailObject.state = zipCode
                        }
                        if let zipCode = record["state_id"] as? String
                        {
                            OrderDetailObject.state_id = zipCode
                        }
                        if let companyId = record["company_id"] as? String
                        {
                            OrderDetailObject.company_id = companyId
                        }
                        if let zipCode = record["status_name"] as? String
                        {
                            OrderDetailObject.status_name = zipCode
                        }
                        if let zipCode = record["zipcode"] as? String
                        {
                            OrderDetailObject.zipcode = zipCode
                        }
                        if let zipCode = record["reschedule_reson"] as? String
                        {
                            OrderDetailObject.reschedule_reson = zipCode
                        }
                        
                        //Urvish
                        if let zipCode = record["tech_fee_labor"] as? String
                        {
                            OrderDetailObject.tech_fee_labor = zipCode
                        }
                        if let zipCode = record["tech_fee_mileage"] as? String
                        {
                            OrderDetailObject.tech_fee_mileage = zipCode
                        }
                        if let zipCode = record["tech_total_fee"] as? String
                        {
                            OrderDetailObject.tech_total_fee = zipCode
                        }
                        if let zipCode = record["tech_fee_parts"] as? String
                        {
                            OrderDetailObject.tech_fee_parts = zipCode
                        }
                        
                        if let zipCode = record["merge_tech_fee_labor"] as? String
                        {
                            OrderDetailObject.merge_tech_fee_labor = zipCode
                        }
                        if let zipCode = record["merge_tech_fee_mileage"] as? String
                        {
                            OrderDetailObject.merge_tech_fee_mileage = zipCode
                        }
                        if let zipCode = record["merge_tech_fee_parts"] as? String
                        {
                            OrderDetailObject.merge_tech_fee_parts = zipCode
                        }
                        if let zipCode = record["merge_tech_total_fee"] as? String
                        {
                            OrderDetailObject.merge_tech_total_fee = zipCode
                        }
                        if let zipCode = record["signature_status"] as? String
                        {
                            OrderDetailObject.signature_status = zipCode
                        }
                        if let dictImageConfige:NSDictionary = record["imageConfig"] as? NSDictionary
                        {
                            if let zipCode = dictImageConfige["heigth"] as? String
                            {
                                OrderDetailObject.heigth = zipCode
                            }
                            
                            if let zipCode = dictImageConfige["width"] as? String
                            {
                                OrderDetailObject.width = zipCode
                            }
                        }
                        
                        
                        

                        do{
                            try OrderDetailObject.managedObjectContext?.save()
                        }catch{
                            ////print("Failed to save city object :: At Index = \(index)")
                        }
                    }
                    else
                    {
                        ////Update the sub technician data
                        if let objCoreDataOrderData:OrderDetailTable = responseCheckRecord.objCoreDataOrderDetail
                        {
                            var objOrder:CRMJob = CRMJob.init(WithCoreDataObject: objCoreDataOrderData)
                            objOrder = objOrder.setPhotoOrVideoOrTask(withModel: objOrder, withContent: record as NSDictionary)
                            self.updateOrderDetails(withOrderObject: objOrder, withIsModifyStatus: false, withModifyDate: Date())
                            ////print("ORderId already exist :: At Index = \(index)")
                        }
                    }
                }
                
            }else{
                ////print("Failed to create entity :: At Index = \(index)")
            }
        }
    }
    func insertPartsDataInCoreData(withArray aryPartsDetails:[CRMPartDetails]) -> Void
    {
        
        for index in 0..<aryPartsDetails.count
        {
            // Create Entity
            if let entity = NSEntityDescription.entity(forEntityName: "PartsDetails", in: self.managedObjectContext)
            {
                // Initialize Record
                let record:CRMPartDetails = aryPartsDetails[index];
                if let value = record.part_id as? String
                {
                    let responseCheckRecord = self.checkPartsDetailsAvailableInCoreData(fromPartId: value)
                    if responseCheckRecord.isRecordAvailable == false
                    {
                        let PartsDetailObject = PartsDetails(entity:entity , insertInto:self.managedObjectContext) as PartsDetails
                        
                        if record.item_id.characters.count > 0
                        {
                            PartsDetailObject.item_id = record.item_id
                        }
                        if record.order_id.characters.count > 0
                        {
                            PartsDetailObject.order_id = record.order_id
                        }
                        if record.user_id.characters.count > 0
                        {
                            PartsDetailObject.user_id = value
                        }
                        
                        if record.date_ordered.characters.count > 0
                        {
                            PartsDetailObject.date_ordered = record.date_ordered
                        }
                        if record.vendor_confm.characters.count > 0
                        {
                            PartsDetailObject.vendor_confm = record.vendor_confm
                        }
                        if record.part_detail.characters.count > 0
                        {
                            PartsDetailObject.part_detail = record.part_detail
                        }
                        if record.part_defect.characters.count > 0
                        {
                            PartsDetailObject.part_defect = record.part_defect
                        }
                        if record.cost.characters.count > 0
                        {
                            PartsDetailObject.cost = record.cost
                        }
                        if record.shipping_amt.characters.count > 0
                        {
                            PartsDetailObject.shipping_amt = record.shipping_amt
                        }
                        if record.first_name.characters.count > 0
                        {
                            PartsDetailObject.first_name = record.first_name
                        }
                        if record.last_name.characters.count > 0
                        {
                            PartsDetailObject.last_name = record.last_name
                        }
                        if record.company.characters.count > 0
                        {
                            PartsDetailObject.company = record.company
                        }
                        if record.address1.characters.count > 0
                        {
                            PartsDetailObject.address1 = record.address1
                        }
                        if record.address2.characters.count > 0
                        {
                            PartsDetailObject.address2 = record.address2
                        }
                        if record.city.characters.count > 0
                        {
                            PartsDetailObject.city = record.city
                        }
                        if record.state.characters.count > 0
                        {
                            PartsDetailObject.state = record.state
                        }
                        if record.zipcode.characters.count > 0
                        {
                            PartsDetailObject.zipcode = record.zipcode
                        }
                        if record.memo.characters.count > 0
                        {
                            PartsDetailObject.memo = record.memo
                        }
                        PartsDetailObject.createdDate = record.createdDate as NSDate?
                        
                        PartsDetailObject.modifiedDate = record.modifiedDate as NSDate?
                        
                        
                        if record.upload_status.characters.count > 0
                        {
                            PartsDetailObject.upload_status = record.upload_status
                        }
                        if record.part_id.characters.count > 0
                        {
                            PartsDetailObject.part_id = record.part_id
                        }
                        
                        if record.upload_pdf.characters.count > 0
                        {
                            PartsDetailObject.upload_pdf = record.upload_pdf
                        }
                        if record.part_status.characters.count > 0
                        {
                            PartsDetailObject.part_status = record.part_status
                        }
                        if record.status_date.characters.count > 0
                        {
                            PartsDetailObject.status_date = record.status_date
                        }
                        if record.status.characters.count > 0
                        {
                            PartsDetailObject.status = record.status
                        }
                        if record.company_id.characters.count > 0
                        {
                            PartsDetailObject.company_id = record.company_id
                        }
                        PartsDetailObject.isDeletedPart = ""
                        
                        
                        do{
                            try PartsDetailObject.managedObjectContext?.save()
                        }catch{
                            ////print("Failed to save city object :: At Index = \(index)")
                        }
                    }
                    else
                    {
                        ////Update the sub technician data
                        if let objCoreDataOrderData:PartsDetails = responseCheckRecord.objCoreDataPartDetails
                        {
                            let objPart:CRMPartDetails = CRMPartDetails.init(withCoreData: objCoreDataOrderData)
                            self.updatePartsDetailsInCoreData(withPartObject: objPart, withIsModifyStatus: false, withModifyDate: Date())
                        }
                    }
                }
                
            }else{
                ////print("Failed to create entity :: At Index = \(index)")
            }
        }
    }
    func insertPartsDataInCoreDataWhenInOffline(withArray aryPartsDetails:[CRMPartDetails]) -> Void
    {
        
        for index in 0..<aryPartsDetails.count
        {
            // Create Entity
            if let entity = NSEntityDescription.entity(forEntityName: "PartsDetails", in: self.managedObjectContext)
            {
                // Initialize Record
                let record:CRMPartDetails = aryPartsDetails[index];
                if record.part_detail.characters.count > 0
                {
                    let PartsDetailObject = PartsDetails(entity:entity , insertInto:self.managedObjectContext) as PartsDetails
                    
                    if record.item_id.characters.count > 0
                    {
                        PartsDetailObject.item_id = record.item_id
                    }
                    if record.order_id.characters.count > 0
                    {
                        PartsDetailObject.order_id = record.order_id
                    }
                    if record.user_id.characters.count > 0
                    {
                        PartsDetailObject.user_id = CRMUser.shared.userId
                    }
                    
                    if record.date_ordered.characters.count > 0
                    {
                        PartsDetailObject.date_ordered = record.date_ordered
                    }
                    if record.vendor_confm.characters.count > 0
                    {
                        PartsDetailObject.vendor_confm = record.vendor_confm
                    }
                    if record.part_detail.characters.count > 0
                    {
                        PartsDetailObject.part_detail = record.part_detail
                    }
                    if record.part_defect.characters.count > 0
                    {
                        PartsDetailObject.part_defect = record.part_defect
                    }
                    if record.cost.characters.count > 0
                    {
                        PartsDetailObject.cost = record.cost
                    }
                    if record.shipping_amt.characters.count > 0
                    {
                        PartsDetailObject.shipping_amt = record.shipping_amt
                    }
                    if record.first_name.characters.count > 0
                    {
                        PartsDetailObject.first_name = record.first_name
                    }
                    if record.last_name.characters.count > 0
                    {
                        PartsDetailObject.last_name = record.last_name
                    }
                    if record.company.characters.count > 0
                    {
                        PartsDetailObject.company = record.company
                    }
                    if record.address1.characters.count > 0
                    {
                        PartsDetailObject.address1 = record.address1
                    }
                    if record.address2.characters.count > 0
                    {
                        PartsDetailObject.address2 = record.address2
                    }
                    if record.city.characters.count > 0
                    {
                        PartsDetailObject.city = record.city
                    }
                    if record.state.characters.count > 0
                    {
                        PartsDetailObject.state = record.state
                    }
                    if record.zipcode.characters.count > 0
                    {
                        PartsDetailObject.zipcode = record.zipcode
                    }
                    if record.memo.characters.count > 0
                    {
                        PartsDetailObject.memo = record.memo
                    }
                    
                    
                    if record.upload_status.characters.count > 0
                    {
                        PartsDetailObject.upload_status = record.upload_status
                    }
                    if record.part_id.characters.count > 0
                    {
                        PartsDetailObject.part_id = record.part_id
                    }
                    
                    if record.upload_pdf.characters.count > 0
                    {
                        PartsDetailObject.upload_pdf = record.upload_pdf
                    }
                    if record.part_status.characters.count > 0
                    {
                        PartsDetailObject.part_status = record.part_status
                    }
                    if record.status_date.characters.count > 0
                    {
                        PartsDetailObject.status_date = record.status_date
                    }
                    if record.status.characters.count > 0
                    {
                        PartsDetailObject.status = record.status
                    }
                    if record.company_id.characters.count > 0
                    {
                        PartsDetailObject.company_id = record.company_id
                    }
                    PartsDetailObject.isDeletedPart = ""
                    PartsDetailObject.createdDate = Date() as NSDate
                    PartsDetailObject.modifiedDate = Date() as NSDate
                    
                    do{
                        try PartsDetailObject.managedObjectContext?.save()
                    }catch{
                        ////print("Failed to save city object :: At Index = \(index)")
                    }
                }
                
            }else{
                ////print("Failed to create entity :: At Index = \(index)")
            }
        }
    }
    
    func insertTaskDataInCoreData(withArray aryTask:[CRMTask]) -> Void
    {
        for index in 0..<aryTask.count
        {
            if let entity = NSEntityDescription.entity(forEntityName: "Task", in: self.managedObjectContext)
            {
                let record:CRMTask = aryTask[index];
                if record.itemId.characters.count > 0
                {
                    let responseRecordCheck = self.checkTaskTableExistInCoreData(fromOId: record.itemId)
                    if responseRecordCheck.isRecordAvailable == false
                    {
                        
                        let TaskObject = Task(entity:entity , insertInto:self.managedObjectContext) as Task
                        /*
                         TaskObject.company = record.company
                         TaskObject.item_id = record.itemId
                         TaskObject.model = record.model
                         TaskObject.title = record.title
                         TaskObject.order_id = record.orderId;
                         */
                        
                        TaskObject.ack = record.SN_ID_ACK
                        TaskObject.additional_info = record.additionalInfo
                        if let value:Int16 = record.cause.id as? Int16
                        {
                            TaskObject.cause = "\(value)"
                        }
                        if let value:Int64 = record.subCause.id as? Int64
                        {
                            TaskObject.cause_reason = "\(value)"
                        }
                        
                        TaskObject.other_cause_reason = record.reasonOfCause
                        TaskObject.company_id = record.companyId
                        if let value:Int64 = record.condition.id as? Int64
                        {
                            TaskObject.condition = "\(value)"
                        }
                        
                        
                        TaskObject.creator_id = record.creatorId
                        TaskObject.delete_status = record.deleteStatus
                        TaskObject.estimate_only_price = record.estimatedOnlyPrice
                        TaskObject.item_id = record.itemId
                        TaskObject.item_photos = record.itemPhotos
                        TaskObject.itm_no = record.itemNo
                        TaskObject.mfg_date = record.MFG_Date
                        TaskObject.model = record.model
                        TaskObject.order_id = record.orderId
                        TaskObject.part_confirmation = record.partConfirmation
                        TaskObject.retail_price = record.retailPrice
                        TaskObject.revised_comments = record.revisedComments
                        if let value:Int64 = record.taskType.id as? Int64
                        {
                            TaskObject.service_type = "\(value)"
                        }
                        if let value:Int64 = record.status.id as? Int64
                        {
                            TaskObject.status = "\(value)"
                        }
                        
                        TaskObject.style = record.style
                        TaskObject.tech_service_item_date = record.techServiceItemDate
                        TaskObject.technician_comment = record.techComments
                        TaskObject.title = record.title
                        TaskObject.vendor_id = record.vendor.user_id
                        TaskObject.company = record.company
                        TaskObject.isModify = false
                        //TaskObject.modified_date = record.modified
                        
                        if record.created.characters.count > 0
                        {
                            if record.created.getDate(withDateFormate: "yyyy-MM-dd HH:mm:ss") != nil
                            {
                                let value:Date = record.created.getDate(withDateFormate: "yyyy-MM-dd HH:mm:ss")!
                                TaskObject.created_date = value as NSDate
                            }
                            
                        }
                        if record.partNeed.count > 0
                        {
                            TaskObject.parts_needed1 = record.partNeed[0]
                        }
                        if record.partNeed.count > 1
                        {
                            TaskObject.parts_needed2 = record.partNeed[1]
                            
                        }
                        if record.partNeed.count > 2
                        {
                            TaskObject.parts_needed3 = record.partNeed[2]
                            
                        }
                        if record.partNeed.count > 3
                        {
                            TaskObject.parts_needed4 = record.partNeed[3]
                            
                        }
                        self.updateTaskPhotosInCoreData(fromTaskObject: record)
                        self.updateTaskVideosInCoreData(fromTaskObject: record)
                        
                        
                        do{
                            try TaskObject.managedObjectContext?.save()
                        }catch{
                            ////print("Failed to save city object :: At Index = \(index)")
                        }
                        
                    }
                    else
                    {
                        self.updateTask(withTaskObject: record, withIsModifyStatus: false, withModifyDate: Date())
                        
                    }
                }
                
            }
        }
    }
    
    //Urvish
    func insertMattressDataInCoreData(withArray aryMattress:[CRMMattress]) -> Void
    {
        for index in 0..<aryMattress.count
        {
            if let entity = NSEntityDescription.entity(forEntityName: "Mettress", in: self.managedObjectContext)
            {
                let record:CRMMattress = aryMattress[index];
                if record.mattressId.characters.count > 0
                {
                    let responseRecordCheck = self.checkMattressTableExistInCoreData(fromOId: record.mattressId)
                    if responseRecordCheck.isRecordAvailable == false
                    {
                        
                        let MattressObject = Mettress(entity:entity , insertInto:self.managedObjectContext) as Mettress
                        
                        //                        MattressObject.matter_id = record.mattressId
                        //                        MattressObject.frame_type = record.frameType
                        //                        MattressObject.label_name = record.labelName
                        //                        MattressObject.mat_mfg = record.mattressDOB
                        //                        MattressObject.manufacturer = record.manufacturer;
                        //                        MattressObject.prod_type = record.productType;
                        //                        MattressObject.recommended = record.recommendedAction;
                        //                        MattressObject.order_id = record.orderId;
                        
                        MattressObject.any_damage = record.mattressHaveDamage
                        MattressObject.box = record.box
                        MattressObject.box_description = record.boxReport
                        MattressObject.cause = "\(record.cause.id)"
                        MattressObject.cause_reason = "\(record.subCause.id)"
                        MattressObject.other_cause_reason = record.reasonOfCause
                        MattressObject.company_id = record.companyId
                        MattressObject.creator_id = record.creatorId
                        if record.createdDate.characters.count > 0
                        {
                            if record.createdDate.getDate(withDateFormate: "yyyy-MM-dd HH:mm:ss") != nil
                            {
                                let value:Date = record.createdDate.getDate(withDateFormate: "yyyy-MM-dd HH:mm:ss")!
                                MattressObject.created_date = value as NSDate
                                
                            }
                        }
                        MattressObject.delete_status = record.deleteStatus
                        MattressObject.description_title = record.strDescription
                        MattressObject.firmness = record.firmness
                        MattressObject.frame_type = record.frameType
                        MattressObject.frame_slats = record.frameWithSlate
                        MattressObject.frame_description = record.frameReport
                        MattressObject.have_stains = record.mattressHaveStains
                        MattressObject.label_name = record.labelName
                        MattressObject.label_code = record.labelCode
                        MattressObject.manufacturer = record.manufacturer
                        MattressObject.mat_box_mfg = record.mattressDOB
                        MattressObject.mat_firmother = record.firmnessOther
                        MattressObject.mat_description = record.mattressReport
                        MattressObject.mat_law_tag = record.lawTagsAttachedToMattress
                        MattressObject.mat_match_box = record.doesBoxMatchMattress
                        MattressObject.mat_mfg = record.foundationDOB
                        MattressObject.mat_productname = record.productName
                        MattressObject.mat_size = record.size
                        MattressObject.matter_id = record.mattressId
                        MattressObject.order_id = record.orderId
                        MattressObject.other = record.other
                        MattressObject.pillow_top = record.pillowTop
                        MattressObject.prod_type = record.productType
                        MattressObject.recommended = record.recommendedAction
                        MattressObject.single_sided = record.singleSided
                        
                        self.updateMattressPhotosInCoreData(fromMattressObject: record)
                        self.updateMattressVideosInCoreData(fromMattressObject: record)
                        
                        
                        do{
                            try MattressObject.managedObjectContext?.save()
                        }catch{
                            ////print("Failed to save city object :: At Index = \(index)")
                        }
                        
                    }
                }
                
            }
        }
    }
    
    
    func insertInvoicesListData(withArray aryInvoicesList:[[String:Any]]) -> Void
    {
        for index in 0..<aryInvoicesList.count
        {
            // Create Entity
            if let entity = NSEntityDescription.entity(forEntityName: "Invoice", in: self.managedObjectContext)
            {
                // Initialize Record
                let record:[String:Any] = aryInvoicesList[index];
                if let value = record["invoice_id"] as? String
                {
                    if self.checkInvoicesExistInCoreData(fromUserId: value)
                    {
                        let InvoiceObject = Invoice(entity:entity , insertInto:self.managedObjectContext) as Invoice
                        
                        if let amount = record["amount"] as? String
                        {
                            InvoiceObject.amount = amount
                        }
                        if let applied = record["applied"] as? String
                        {
                            InvoiceObject.applied = applied
                        }
                        if let desc = record["description"] as? String
                        {
                            InvoiceObject.desc = desc
                        }
                        
                        if let diffrence = record["difference_amt"] as? String
                        {
                            InvoiceObject.diffrence = diffrence
                        }
                        
                        if let invoiceDate = record["invoice_date"] as? String
                        {
                            InvoiceObject.date = invoiceDate
                        }
                        
                        if let type = record["invoice_type"] as? String
                        {
                            InvoiceObject.type = type
                        }
                        
                        if let status = record["status"] as? String
                        {
                            InvoiceObject.status = status
                        }
                        if let invoiceID = record["invoice_id"] as? String
                        {
                            InvoiceObject.id = invoiceID
                        }
                        
                        do{
                            try InvoiceObject.managedObjectContext?.save()
                        }catch{
                            ////print("Failed to save city object :: At Index = \(index)")
                        }
                    }
                    else
                    {
                        ////Update the invoice data
                        ////print(record);
                        let objInvoice:CRMInvoices = CRMInvoices.init(withContent: record as NSDictionary)
                        self.updateInvoiceList(withInvoiceList: objInvoice, withIsModifyStatus: false, withModifyDate: Date())
                        
                        ////print("Invoice already exist :: At Index = \(index)")
                    }
                }
                
            }else{
                ////print("Failed to create entity :: At Index = \(index)")
            }
        }
        
        
    }
    func insertLogDataInTable(withEditRecordId recordId:String, withMessage message:String, withModuleId module:String) -> Void
    {
        // Create Entity
        if let entity = NSEntityDescription.entity(forEntityName: "Log", in: self.managedObjectContext)
        {
            // Initialize Record
            //let record:[String:Any] = OrderDetailsData;
            let LogObject = Log(entity:entity , insertInto:self.managedObjectContext) as Log
            LogObject.id = "\(self.getLogTalbeCount() + 1)"
            LogObject.company_id = CRMUser.shared.companyId
            LogObject.message  = message
            LogObject.user_id = CRMUser.shared.userId
            LogObject.edit_record_id =  recordId
            LogObject.module = module
            LogObject.created_date = Date() as NSDate?
            
            do{
                try LogObject.managedObjectContext?.save()
            }catch{
                ////print("Failed to save OrderStatus object :: At Index = \(index)")
            }
        }else{
            ////print("Failed to create entity OrderStatus :: At Index = \(index)")
        }
    }
    
    func insertOrderStatusTable(withOrderDetails orderJobs:CRMJob) -> Void
    {
        // Create Entity
        if let entity = NSEntityDescription.entity(forEntityName: "OrderStatusTable", in: self.managedObjectContext)
        {
            // Initialize Record
            //let record:[String:Any] = OrderDetailsData;
            if Int(orderJobs.o_id) != 0
            {
                let OrderStatusObject = OrderStatusTable(entity:entity , insertInto:self.managedObjectContext) as OrderStatusTable
                OrderStatusObject.o_id = orderJobs.o_id
                OrderStatusObject.company_id = CRMUser.shared.companyId
                OrderStatusObject.user_id = CRMUser.shared.userId
                OrderStatusObject.service_status = "\(orderJobs.serviceStatus.id)"
                OrderStatusObject.modifyDate = Date() as NSDate?
                OrderStatusObject.setValue(NSNumber.init(value: true), forKey: "isModify")
                self.updateOrderDetails(withOrderObject: orderJobs, withIsModifyStatus: true, withModifyDate: Date())
                
                do{
                    try OrderStatusObject.managedObjectContext?.save()
                }catch{
                    ////print("Failed to save OrderStatus object :: At Index = \(index)")
                }
            }
            
        }else{
            ////print("Failed to create entity OrderStatus :: At Index = \(index)")
        }
        
        
        
    }
    func insertOrderScheduleTable(withOrderDetails orderJobs:CRMJob) -> Void
    {
        // Create Entity
        if let entity = NSEntityDescription.entity(forEntityName: "OrderScheduleTable", in: self.managedObjectContext)
        {
            // Initialize Record
            //let record:[String:Any] = OrderDetailsData;
            if Int(orderJobs.o_id) != 0
            {
                let OrderStatusObject = OrderScheduleTable(entity:entity , insertInto:self.managedObjectContext) as OrderScheduleTable
                OrderStatusObject.o_id = orderJobs.o_id
                OrderStatusObject.company_id = CRMUser.shared.companyId
                OrderStatusObject.user_id = CRMUser.shared.userId
                OrderStatusObject.apntmnt_date = orderJobs.appointmentDate
                OrderStatusObject.apntmnt_time = orderJobs.appointmentTime
                OrderStatusObject.isModify = true
                OrderStatusObject.modifyDate = Date() as NSDate?
                if orderJobs.isSchedule == "0"
                {
                    orderJobs.isSchedule = "1"
                }
                else if orderJobs.isSchedule == "1"
                {
                    orderJobs.isSchedule = "2"
                }else if orderJobs.isSchedule == "2"
                {
                    orderJobs.isSchedule = "2"
                }
                OrderStatusObject.reschedule_reson = orderJobs.rescheduleReason
                OrderStatusObject.seven_days_reason = orderJobs.sevenDaysReason
                
                
                self.updateOrderDetails(withOrderObject: orderJobs, withIsModifyStatus: true, withModifyDate: Date())
                
                do
                {
                    try OrderStatusObject.managedObjectContext?.save()
                }
                catch
                {
                    ////print("Failed to save OrderStatus object :: At Index = \(index)")
                }
            }
            
        }else{
            ////print("Failed to create entity OrderStatus :: At Index = \(index)")
        }
        
        
        
    }
    
    
    
    func insertPhotoTable(withPhotoDetails aryPhoto:[CRMImage]) -> Void
    {
        
        // Create Entity
        if let entity = NSEntityDescription.entity(forEntityName: "Photo", in: self.managedObjectContext)
        {
            // Initialize Record
            //let record:[String:Any] = OrderDetailsData;
            for photo in aryPhoto
            {
                let objPhoto:CRMImage = photo
                
                if objPhoto.imageLocalLocation.characters.count > 0 && objPhoto.isAddedInDatabase == true
                {
                    /*
                     if self.checkPhotoAvailableInCoreData(fromLocalFilePath: objPhoto.imageLocalLocation, withItemId: objPhoto.orderItemId, withOrderId: objPhoto.orderId)
                     {
                     
                     }
                     */
                    
                    let PhotoObject = Photo(entity:entity , insertInto:self.managedObjectContext) as Photo
                    PhotoObject.p_id = "\(objPhoto.imageId)"
                    PhotoObject.photo_name = objPhoto.imageName
                    PhotoObject.order_id = objPhoto.orderId
                    PhotoObject.order_item_id = objPhoto.orderItemId
                    PhotoObject.type = objPhoto.type
                    PhotoObject.isDelete = false
                    PhotoObject.localFileUrl = objPhoto.imageLocalLocation
                    PhotoObject.modified_date = Date() as NSDate?
                    PhotoObject.created_date = Date() as NSDate?
                    PhotoObject.company_id = objPhoto.companyId
                    PhotoObject.file_key = objPhoto.fileKey
                    PhotoObject.upload_status = objPhoto.uploadStatus
                    PhotoObject.mine_type = objPhoto.imageMineType
                    
                    do
                    {
                        try PhotoObject.managedObjectContext?.save()
                    }
                    catch
                    {
                        ////print("Failed to save OrderStatus object :: At Index = \(index)")
                    }
                    
                }
                else
                {
                    if self.checkPhotoAvailableInCoreData(fromPId: "\(objPhoto.imageId)") == false
                    {
                        let PhotoObject = Photo(entity:entity , insertInto:self.managedObjectContext) as Photo
                        PhotoObject.p_id = "\(objPhoto.imageId)"
                        PhotoObject.photo_name = objPhoto.imageName
                        PhotoObject.order_id = objPhoto.orderId
                        PhotoObject.order_item_id = objPhoto.orderItemId
                        PhotoObject.type = objPhoto.type
                        PhotoObject.isDelete = false
                        PhotoObject.localFileUrl = objPhoto.imageLocalLocation
                        PhotoObject.modified_date = Date() as NSDate?
                        PhotoObject.created_date = Date() as NSDate?
                        PhotoObject.company_id = objPhoto.companyId
                        PhotoObject.upload_status = objPhoto.uploadStatus
                        PhotoObject.file_key = objPhoto.fileKey
                        PhotoObject.mine_type = objPhoto.imageMineType;
                        
                        do
                        {
                            try PhotoObject.managedObjectContext?.save()
                        }
                        catch
                        {
                            ////print("Failed to save OrderStatus object :: At Index = \(index)")
                        }
                    }
                }
            }
        }else{
            ////print("Failed to create entity OrderStatus :: At Index = \(index)")
        }
        
        
    }
    /*
     func insertPhotoInTable(withPhotoObject objPhoto:CRMImage) -> Void
     {
     
     // Create Entity
     if let entity = NSEntityDescription.entity(forEntityName: "Photo", in: self.managedObjectContext)
     {
     // Initialize Record
     //let record:[String:Any] = OrderDetailsData;
     if objPhoto.imageLocalLocation.characters.count > 0
     {
     let PhotoObject = Photo(entity:entity , insertInto:self.managedObjectContext) as Photo
     PhotoObject.p_id = "\(objPhoto.imageId)"
     PhotoObject.photo_name = objPhoto.imageName
     PhotoObject.order_id = objPhoto.orderId
     PhotoObject.order_item_id = objPhoto.orderItemId
     PhotoObject.type = objPhoto.type
     PhotoObject.isDelete = false
     PhotoObject.localFileUrl = objPhoto.imageLocalLocation
     PhotoObject.modified_date = Date() as NSDate?
     PhotoObject.created_date = Date() as NSDate?
     PhotoObject.company_id = objPhoto.companyId
     PhotoObject.upload_status = objPhoto.uploadStatus
     PhotoObject.file_key = objPhoto.fileKey
     PhotoObject.mine_type = objPhoto.imageMineType;
     
     do
     {
     try PhotoObject.managedObjectContext?.save()
     }
     catch
     {
     ////print("Failed to save OrderStatus object :: At Index = \(index)")
     }
     }
     else
     {
     if self.checkPhotoAvailableInCoreData(fromPId: "\(objPhoto.imageId)") == false
     {
     let PhotoObject = Photo(entity:entity , insertInto:self.managedObjectContext) as Photo
     PhotoObject.p_id = "\(objPhoto.imageId)"
     PhotoObject.photo_name = objPhoto.imageName
     PhotoObject.order_id = objPhoto.orderId
     PhotoObject.order_item_id = objPhoto.orderItemId
     PhotoObject.type = objPhoto.type
     PhotoObject.isDelete = false
     PhotoObject.localFileUrl = objPhoto.imageLocalLocation
     PhotoObject.modified_date = Date() as NSDate?
     PhotoObject.created_date = Date() as NSDate?
     PhotoObject.company_id = objPhoto.companyId
     PhotoObject.upload_status = objPhoto.uploadStatus
     PhotoObject.file_key = objPhoto.fileKey
     PhotoObject.mine_type = objPhoto.imageMineType;
     
     do
     {
     try PhotoObject.managedObjectContext?.save()
     }
     catch
     {
     ////print("Failed to save OrderStatus object :: At Index = \(index)")
     }
     }
     }
     
     
     
     }else{
     ////print("Failed to create entity OrderStatus :: At Index = \(index)")
     }
     
     
     }
     */
    
    func insertVideoTable(withVideoDetails aryVideo:[CRMVideo]) -> Void
    {
        
        // Create Entity
        if let entity = NSEntityDescription.entity(forEntityName: "Video", in: self.managedObjectContext)
        {
            // Initialize Record
            //let record:[String:Any] = OrderDetailsData;
            for video  in aryVideo
            {
                let objVideo:CRMVideo = video
                
                
                if objVideo.localPath.characters.count > 0 && objVideo.isAddInDatabase == true
                {
                    let VideoObject = Video(entity:entity , insertInto:self.managedObjectContext) as Video
                    VideoObject.v_id = "\(objVideo.videoId)"
                    VideoObject.video_name = objVideo.fileName
                    VideoObject.video_image = objVideo.videoImage
                    VideoObject.order_id = objVideo.orderId
                    VideoObject.order_item_id = objVideo.orderItemId
                    VideoObject.type = objVideo.type
                    VideoObject.isDelete = false
                    VideoObject.localFileUrl = objVideo.localPath;
                    VideoObject.modified_date = Date() as NSDate?
                    VideoObject.created_date = Date() as NSDate?
                    VideoObject.company_id = objVideo.company_id
                    VideoObject.file_key = objVideo.fileKey
                    VideoObject.upload_status = objVideo.upload_status
                    VideoObject.mine_type = objVideo.fileExtenstion
                    
                    do
                    {
                        try VideoObject.managedObjectContext?.save()
                    }
                    catch
                    {
                        ////print("Failed to save OrderStatus object :: At Index = \(index)")
                    }
                    
                    
                }
                else
                {
                    if self.checkVideoAvailableInCoreData(fromVId: "\(objVideo.videoId)") == false
                    {
                        let VideoObject = Video(entity:entity , insertInto:self.managedObjectContext) as Video
                        VideoObject.v_id = "\(objVideo.videoId)"
                        VideoObject.video_name = objVideo.fileName
                        VideoObject.video_image = objVideo.videoImage
                        VideoObject.order_id = objVideo.orderId
                        VideoObject.order_item_id = objVideo.orderItemId
                        VideoObject.type = objVideo.type
                        VideoObject.isDelete = false
                        VideoObject.localFileUrl = objVideo.localPath;
                        VideoObject.modified_date = Date() as NSDate?
                        VideoObject.created_date = Date() as NSDate?
                        VideoObject.company_id = objVideo.company_id
                        VideoObject.file_key = objVideo.fileKey
                        VideoObject.upload_status = objVideo.upload_status
                        VideoObject.mine_type = objVideo.fileExtenstion
                        
                        do
                        {
                            try VideoObject.managedObjectContext?.save()
                        }
                        catch
                        {
                            ////print("Failed to save OrderStatus object :: At Index = \(index)")
                        }
                    }
                }
            }
        }else{
            ////print("Failed to create entity OrderStatus :: At Index = \(index)")
        }
        
    }
    
    func insertInvoiceDetail(withArray aryInvoiceDetail:[[String:Any]]) -> Void
    {
        for index in 0..<aryInvoiceDetail.count
        {
            // Create Entity
            if let entity = NSEntityDescription.entity(forEntityName: "InvoiceDetail", in: self.managedObjectContext)
            {
                // Initialize Record
                let record:[String:Any] = aryInvoiceDetail[index];
                if let value = record["id"] as? String
                {
                    if let oId = record["o_Id"] as? String
                    {
                        if self.checkInvoiceDetailExistInCoreData(fromUserId: value, oId: oId) //(fromUserId: value)
                        {
                            let InvoiceObject = InvoiceDetail(entity:entity , insertInto:self.managedObjectContext) as InvoiceDetail
                            
                            if let value = record["apntmnt_date"] as? String
                            {
                                InvoiceObject.apointmentdate = value
                            }
                            if let value = record["first_name"] as? String
                            {
                                InvoiceObject.firstname = value
                            }
                            if let value = record["last_name"] as? String
                            {
                                InvoiceObject.lastname = value
                            }
                            
                            if let value = record["o_Id"] as? String
                            {
                                InvoiceObject.oid = value
                            }
                            
                            if let value = record["status_name"] as? String
                            {
                                InvoiceObject.statusname = value
                            }
                            
                            if let value = record["tech_fee_labor"] as? String
                            {
                                InvoiceObject.techlabor = value
                            }
                            if let value = record["tech_fee_mileage"] as? String
                            {
                                InvoiceObject.techmileage = value
                            }
                            if let value = record["tech_fee_parts"] as? String
                            {
                                InvoiceObject.techparts = value
                            }
                            
                            if let value = record["tech_total_fee"] as? String
                            {
                                InvoiceObject.techtotalfee = value
                            }
                            if let value = record["id"] as? String
                            {
                                InvoiceObject.id = value
                            }
                            
                            do{
                                try InvoiceObject.managedObjectContext?.save()
                            }catch{
                                ////print("Failed to save city object :: At Index = \(index)")
                            }
                        }
                        else
                        {
                            ////Update the invoice data
                            ////print(record);
                            let objInvoice:CRMInvoiceOrder = CRMInvoiceOrder.init(withContent: record as NSDictionary)
                            self.updateInvoiceDetail(withInvoiceList: objInvoice)
                            
                            ////print("Invoice already exist :: At Index = \(index)")
                        }
                    }
                    
                }
                
            }else{
                ////print("Failed to create entity :: At Index = \(index)")
            }
        }
    }
    func insertSignaturePhotosInCoreData(fromOrderDetails objImage:CRMImage) -> Void
    {
        self.insertPhotoTable(withPhotoDetails: [objImage])
        
    }
    func insertSeeLogsInCoreData(withArray arySeeLogs:[[String:Any]]) -> Void
    {
        for index in 0..<arySeeLogs.count
        {
            // Create Entity
            if let entity = NSEntityDescription.entity(forEntityName: "SeeLog", in: self.managedObjectContext)
            {
                // Initialize Record
                let record:[String:Any] = arySeeLogs[index];
                if let value = record["id"] as? String
                {
                    if let id = record["id"] as? String
                    {
                        if self.checkSeeLogsInCoreData(fromOrderId: id) //(fromUserId: value)
                        {
                            
                            let SeeLogObject = SeeLog(entity:entity , insertInto:self.managedObjectContext) as SeeLog
                            
                            if let value = record["company_id"] as? String
                            {
                                SeeLogObject.company_id = value
                            }
                            if let value = record["created"] as? String
                            {
                                SeeLogObject.created = value
                            }
                            if let value = record["email_status"] as? String
                            {
                                SeeLogObject.email_status = value
                            }
                            
                            if let value = record["group_id"] as? String
                            {
                                SeeLogObject.group_id = value
                            }
                            
                            if let value = record["id"] as? String
                            {
                                SeeLogObject.id = value
                            }
                            
                            if let value = record["log_id"] as? String
                            {
                                SeeLogObject.log_id = value
                            }
                            if let value = record["memo_cate_id"] as? String
                            {
                                SeeLogObject.memo_cate_id = value
                            }
                            if let value = record["memo_msg"] as? String
                            {
                                SeeLogObject.memo_msg = value
                            }
                            
                            if let value = record["memo_status"] as? String
                            {
                                SeeLogObject.memo_status = value
                            }
                            if let value = record["memo_txt"] as? String
                            {
                                SeeLogObject.memo_txt = value
                            }
                            if let value = record["modified"] as? String
                            {
                                SeeLogObject.modified = value
                            }
                            if let value = record["order_id"] as? String
                            {
                                SeeLogObject.order_id = value
                            }
                            if let value = record["user_id"] as? String
                            {
                                SeeLogObject.user_id = value
                            }
                            if let value = record["users_id"] as? String
                            {
                                SeeLogObject.users_id = value
                            }
                            
                            do{
                                try SeeLogObject.managedObjectContext?.save()
                            }catch{
                                ////print("Failed to save SeeLogs :: At Index = \(index)")
                            }
                        }
                        else
                        {
                            ////Update the invoice data
                            ////print(record);
                            let objInvoice:CRMLogs = CRMLogs.init(withContent: record as NSDictionary)
                            self.updateSeeLogsInCoreData(withSeeLogObject: objInvoice)
                            
                            ////print("Invoice already exist :: At Index = \(index)")
                        }
                    }
                    
                }
                
            }
            else
            {
                ////print("Failed to create entity :: At Index = \(index)")
            }
        }
    }
    
    //MARK:- Select
    
    func getStateList() -> [CRMState]
    {
        let stateFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "State")
        stateFetchRequest.entity = NSEntityDescription.entity(forEntityName: "State", in: self.managedObjectContext)
        let stateNameSort:NSSortDescriptor = NSSortDescriptor.init(key: "state_name", ascending: true)
        stateFetchRequest.sortDescriptors = [stateNameSort]
        
        do {
            if let stateFetch = try self.managedObjectContext.fetch(stateFetchRequest) as? [State]
            {
                var aryState:[CRMState] = []
                for state in stateFetch{
                    aryState.append(CRMState(WithCoreDataObject: state))
                }
                return aryState
            }else{
                return []
            }
        }catch{
            return []
        }
    }
    func getLastStateData() -> CRMState?
    {
        let stateFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "State")
        stateFetchRequest.entity = NSEntityDescription.entity(forEntityName: "State", in: self.managedObjectContext)
        let sortDescriptor = NSSortDescriptor(key: "modified", ascending: false)
        stateFetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            if let stateFetch = try self.managedObjectContext.fetch(stateFetchRequest) as? [State]
            {
                var state:CRMState?
                if stateFetch.first != nil
                {
                    state = CRMState.init(WithCoreDataObject: stateFetch.first!)
                }
                if state != nil
                {
                    return state!
                }
                else
                {
                    return nil
                }
                
            }else{
                return nil
            }
        }catch{
            return nil
        }
    }
    func getState(fromStateId stateId:String) -> CRMState?
    {
        let stateFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "State")
        stateFetchRequest.entity = NSEntityDescription.entity(forEntityName: "State", in: self.managedObjectContext)
        stateFetchRequest.predicate = NSPredicate.init(format: "state_id = %@", stateId)
        
        do {
            if let stateFetch = try self.managedObjectContext.fetch(stateFetchRequest) as? [State]
            {
                var state:CRMState?
                if stateFetch.first != nil
                {
                    state = CRMState.init(WithCoreDataObject: stateFetch.first!)
                }
                if state != nil
                {
                    return state!
                }
                else
                {
                    return nil
                }
            }else{
                return nil
            }
        }catch{
            return nil
        }
    }
    func getState(fromStateName stateName:String) -> CRMState?
    {
        let stateFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "State")
        stateFetchRequest.entity = NSEntityDescription.entity(forEntityName: "State", in: self.managedObjectContext)
        stateFetchRequest.predicate = NSPredicate.init(format: "state_name = %@", stateName)
        
        do {
            if let stateFetch = try self.managedObjectContext.fetch(stateFetchRequest) as? [State]
            {
                var state:CRMState?
                if stateFetch.first != nil
                {
                    state = CRMState.init(WithCoreDataObject: stateFetch.first!)
                }
                if state != nil
                {
                    return state!
                }
                else
                {
                    return nil
                }
            }else{
                return nil
            }
        }catch{
            return nil
        }
    }
    
    func getCities(ForStateId stateId:String) -> [CRMCity]
    {
        let cityFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "City")
        cityFetchRequest.entity = NSEntityDescription.entity(forEntityName: "City", in: self.managedObjectContext)
        cityFetchRequest.predicate = NSPredicate.init(format: "state_id = %@", stateId)
        
        let cityNameSort:NSSortDescriptor = NSSortDescriptor.init(key: "city_name", ascending: true)
        cityFetchRequest.sortDescriptors = [cityNameSort]
        
        do {
            if let cityFetch = try self.managedObjectContext.fetch(cityFetchRequest) as? [City]
            {
                var aryCity:[CRMCity] = []
                for city in cityFetch{
                    aryCity.append(CRMCity(WithCoreDataObject: city))
                }
                return aryCity
            }else{
                return []
            }
        }catch{
            return []
        }
    }
    func getLastCity() -> CRMCity?
    {
        let cityFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "City")
        cityFetchRequest.entity = NSEntityDescription.entity(forEntityName: "City", in: self.managedObjectContext)
        let sortDescriptor = NSSortDescriptor(key: "modified", ascending: false)
        cityFetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            if let cityFetch = try self.managedObjectContext.fetch(cityFetchRequest) as? [City]
            {
                var city:CRMCity?
                if cityFetch.first != nil
                {
                    city = CRMCity.init(WithCoreDataObject: cityFetch.first!)
                }
                if city != nil
                {
                    return city!
                }
                else
                {
                    return nil
                }
            }else{
                return nil
            }
        }catch{
            return nil
        }
    }
    func getCity(fromCityId cityId:String) -> CRMCity?
    {
        let cityFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "City")
        cityFetchRequest.entity = NSEntityDescription.entity(forEntityName: "City", in: self.managedObjectContext)
        cityFetchRequest.predicate = NSPredicate.init(format: "city_id = %@", cityId)
        
        do {
            if let cityFetch = try self.managedObjectContext.fetch(cityFetchRequest) as? [City]
            {
                var city:CRMCity?
                if cityFetch.first != nil
                {
                    city = CRMCity.init(WithCoreDataObject: cityFetch.first!)
                }
                if city != nil
                {
                    return city!
                }
                else
                {
                    return nil
                }
            }else{
                return nil
            }
        }catch{
            return nil
        }
    }
    func getLastZipData() -> Zip?
    {
        let zipFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Zip")
        zipFetchRequest.entity = NSEntityDescription.entity(forEntityName: "Zip", in: self.managedObjectContext)
        let sortDescriptor = NSSortDescriptor(key: "modified", ascending: false)
        zipFetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            if let zipFetch = try self.managedObjectContext.fetch(zipFetchRequest) as? [Zip]
            {
                var zip:Zip?
                if zipFetch.first != nil
                {
                    zip = zipFetch.first!
                }
                if zip != nil
                {
                    return zip!
                }
                else
                {
                    return nil
                }
            }else{
                return nil
            }
        }catch{
            return nil
        }
    }
    
    func getItemCauseList() -> [CRMItemCause]
    {
        let itemCauseFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Item_cause")
        itemCauseFetchRequest.entity = NSEntityDescription.entity(forEntityName: "Item_cause", in: self.managedObjectContext)
        
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        itemCauseFetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            if let itemCauseFetch = try self.managedObjectContext.fetch(itemCauseFetchRequest) as? [Item_cause]
            {
                var aryItemCause:[CRMItemCause] = []
                for itemCause in itemCauseFetch{
                    aryItemCause.append(CRMItemCause(withCoreDataObject: itemCause))
                }
                return aryItemCause
            }else{
                return []
            }
        }catch{
            return []
        }
    }
    func getAllSubItemCauseList() -> [CRMSubItemCause]
    {
        
        let itemCauseFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "SubItemCause")
        itemCauseFetchRequest.entity = NSEntityDescription.entity(forEntityName: "SubItemCause", in: self.managedObjectContext)
        let sortDescriptor = NSSortDescriptor(key: "reason", ascending: true)
        itemCauseFetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            if let itemCauseFetch = try self.managedObjectContext.fetch(itemCauseFetchRequest) as? [SubItemCause]
            {
                var aryItemCause:[CRMSubItemCause] = []
                for subItemCause in itemCauseFetch{
                    aryItemCause.append(CRMSubItemCause(withCoreDataObject: subItemCause))
                }
                aryItemCause.append(CRMSubItemCause.init(withOtherCauseId: "10000"))
                
                return aryItemCause
            }else{
                return []
            }
        }catch{
            return []
        }
    }
    func getSubItemCauseList(withCauseId causeId:String) -> [CRMSubItemCause]
    {
        
        let itemCauseFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "SubItemCause")
        itemCauseFetchRequest.entity = NSEntityDescription.entity(forEntityName: "SubItemCause", in: self.managedObjectContext)
        if causeId.characters.count > 0
        {
            itemCauseFetchRequest.predicate = NSPredicate.init(format: "cause = %@", causeId)
            
        }
        let sortDescriptor = NSSortDescriptor(key: "reason", ascending: true)
        itemCauseFetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            if let itemCauseFetch = try self.managedObjectContext.fetch(itemCauseFetchRequest) as? [SubItemCause]
            {
                var aryItemCause:[CRMSubItemCause] = []
                for subItemCause in itemCauseFetch{
                    aryItemCause.append(CRMSubItemCause(withCoreDataObject: subItemCause))
                }
                aryItemCause.append(CRMSubItemCause.init(withOtherCauseId: "10000"))
                
                return aryItemCause
            }else{
                return []
            }
        }catch{
            return []
        }
    }
    
    func getSubTechnicianList() -> [CRMSubTechnician]
    {
        let stateFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "SubTechnician")
        stateFetchRequest.entity = NSEntityDescription.entity(forEntityName: "SubTechnician", in: self.managedObjectContext)
        do {
            if let subTechnicianFetch = try self.managedObjectContext.fetch(stateFetchRequest) as? [SubTechnician]
            {
                var arySubTechnician:[CRMSubTechnician] = []
                for subTechnician in subTechnicianFetch{
                    arySubTechnician.append(CRMSubTechnician(WithCoreDataObject: subTechnician))
                    
                }
                return arySubTechnician
            }else{
                return []
            }
        }catch{
            return []
        }
    }
    func getRescheduleReasonList() -> [CRMRescheduleReason]
    {
        
        let itemCauseFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "RescheduleReasons")
        itemCauseFetchRequest.entity = NSEntityDescription.entity(forEntityName: "RescheduleReasons", in: self.managedObjectContext)

        let sortDescriptor = NSSortDescriptor(key: "reason", ascending: true)
        itemCauseFetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            if let itemCauseFetch = try self.managedObjectContext.fetch(itemCauseFetchRequest) as? [RescheduleReasons]
            {
                var aryItemCause:[CRMRescheduleReason] = []
                for subItemCause in itemCauseFetch{
                    aryItemCause.append(CRMRescheduleReason(withCoreDataObject: subItemCause))
                }
                //aryItemCause.append(CRMRescheduleReason.init(withOtherCauseId: "10000"))
                
                return aryItemCause
            }
            else
            {
                return []
            }
        }catch{
            return []
        }
    }
    func getRescheduleReason(withId id:String) -> CRMRescheduleReason
    {
        
        let itemCauseFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "RescheduleReasons")
        itemCauseFetchRequest.entity = NSEntityDescription.entity(forEntityName: "RescheduleReasons", in: self.managedObjectContext)
        itemCauseFetchRequest.predicate = NSPredicate(format: "id = %@", id)
        
        let sortDescriptor = NSSortDescriptor(key: "reason", ascending: true)
        itemCauseFetchRequest.sortDescriptors = [sortDescriptor]
        var objRescheduleReason:CRMRescheduleReason = CRMRescheduleReason()
        
        
        do {
            if let itemCauseFetch = try self.managedObjectContext.fetch(itemCauseFetchRequest) as? [RescheduleReasons]
            {
               
                if itemCauseFetch.count > 0
                {
                    objRescheduleReason = CRMRescheduleReason.init(withCoreDataObject: itemCauseFetch.first!)
                    
                }
                //aryItemCause.append(CRMRescheduleReason.init(withOtherCauseId: "10000"))
                
                return objRescheduleReason
            }
            else
            {
                return objRescheduleReason
            }
        }catch{
            return objRescheduleReason
        }
    }
    
    func getLateScheduleReasonList() -> [CRMLateScheduleReason]
    {
        
        let itemCauseFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "LateScheduleReason")
        itemCauseFetchRequest.entity = NSEntityDescription.entity(forEntityName: "LateScheduleReason", in: self.managedObjectContext)
        
        let sortDescriptor = NSSortDescriptor(key: "reason", ascending: true)
        itemCauseFetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            if let itemCauseFetch = try self.managedObjectContext.fetch(itemCauseFetchRequest) as? [LateScheduleReason]
            {
                var aryItemCause:[CRMLateScheduleReason] = []
                for subItemCause in itemCauseFetch{
                    aryItemCause.append(CRMLateScheduleReason(withCoreDataObject: subItemCause))
                }
                aryItemCause.append(CRMLateScheduleReason.init(withOtherCauseId: "10000"))
                
                return aryItemCause
            }
            else
            {
                return []
            }
        }catch{
            return []
        }
    }
    
    func getSeeLogsList(withOrderId oId:String) -> [CRMLogs]
    {
        let seeLogsFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "SeeLog")
        seeLogsFetchRequest.entity = NSEntityDescription.entity(forEntityName: "SeeLog", in: self.managedObjectContext)
        seeLogsFetchRequest.predicate = NSPredicate.init(format: "order_id = %@", oId)
        
        do {
            if let seeLogsFetch = try self.managedObjectContext.fetch(seeLogsFetchRequest) as? [SeeLog]
            {
                var arySeeLogs:[CRMLogs] = []
                for log in seeLogsFetch
                {
                    arySeeLogs.append(CRMLogs.init(withCoreData: log))
                    
                }
                return arySeeLogs
            }else{
                return []
            }
        }catch{
            return []
        }
    }
    
    func getSubTechnicianDetails(fromUserId userId:String) -> CRMSubTechnician
    {
        let stateFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "SubTechnician")
        stateFetchRequest.entity = NSEntityDescription.entity(forEntityName: "SubTechnician", in: self.managedObjectContext)
        stateFetchRequest.predicate = NSPredicate(format: "user_id = %@", userId)
        
        do {
            if let subTechnicianFetch = try self.managedObjectContext.fetch(stateFetchRequest) as? [SubTechnician]
            {
                var objSubTechnician:CRMSubTechnician = CRMSubTechnician()
                if (subTechnicianFetch.first != nil)
                {
                    objSubTechnician = CRMSubTechnician(WithCoreDataObject: subTechnicianFetch.first!)
                }
                return objSubTechnician
            }else{
                return CRMSubTechnician()
            }
        }catch{
            return CRMSubTechnician()
        }
    }
    func searchOrderList(withOrderNumber orderNumber:String, withContactNumber contact:String, withFirstName firstName:String , withState state:String, withCity city:String, withPageIndex pageIndex:Int) -> [CRMJob]
    {
        var strQuery:String = ""
        if orderNumber.characters.count > 0
        {
            if strQuery.characters.count > 0
            {
                
                strQuery = "\(strQuery) AND client_order_no CONTAINS[cd] '\(orderNumber)'"
            }
            else
            {
                strQuery = "client_order_no CONTAINS[cd] '\(orderNumber)'"
            }
            
        }
        
        if contact.characters.count > 0
        {
            if strQuery.characters.count > 0
            {
                strQuery = "\(strQuery) AND mobile CONTAINS[cd] '\(contact)'"
            }
            else
            {
                strQuery = "mobile CONTAINS[cd] '\(contact)'"
            }
            
        }
        
        
        if firstName.characters.count > 0
        {
            if strQuery.characters.count > 0
            {
                strQuery = "\(strQuery) AND first_name CONTAINS[cd] '\(firstName)' OR last_name CONTAINS[cd] '\(firstName)'"
            }
            else
            {
                strQuery = "first_name CONTAINS[cd] '\(firstName)' OR last_name CONTAINS[cd] '\(firstName)'"
            }
        }
        if state.characters.count > 0
        {
            if strQuery.characters.count > 0
            {
                strQuery = "\(strQuery) AND state_id CONTAINS[cd] '\(state)'"
            }
            else
            {
                strQuery = "state_id CONTAINS[cd] '\(state)'"
            }
        }
        if city.characters.count > 0
        {
            if strQuery.characters.count > 0
            {
                strQuery = "\(strQuery) AND city_id LIKE \(city)"
            }
            else
            {
                strQuery = "city_id LIKE \(city)"
            }
        }
        ////print(strQuery)
        let orderFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "OrderDetailTable")
        orderFetchRequest.entity = NSEntityDescription.entity(forEntityName: "OrderDetailTable", in: self.managedObjectContext)
        let sortDescriptor = NSSortDescriptor(key: "o_id", ascending: false)
        orderFetchRequest.sortDescriptors = [sortDescriptor]
        orderFetchRequest.predicate = NSPredicate(format: "\(strQuery)")
        orderFetchRequest.fetchLimit = 10
        orderFetchRequest.fetchOffset = ( (pageIndex - 1 ) * orderFetchRequest.fetchLimit )
        
        do {
            if let orderFetch = try self.managedObjectContext.fetch(orderFetchRequest) as? [OrderDetailTable]
            {
                var aryOrderList:[CRMJob] = []
                for orderData in orderFetch
                {
                    let objCRMJobs:CRMJob = CRMJob(WithCoreDataObject: orderData)
                    objCRMJobs.photos = self.getPhotoInCoreData(fromOrderId: "0", withOrderItemId: objCRMJobs.o_id, withType: "order")
                    objCRMJobs.videos = self.getVideoInCoreData(fromOrderId: "0", withOrderItemId: objCRMJobs.o_id, withType: "order")
                    objCRMJobs.orderTasks = self.getTask(fromOId: objCRMJobs.o_id)
                    objCRMJobs.orderMattress = self.getMattress(fromOId: objCRMJobs.o_id)
                    
                    aryOrderList.append(objCRMJobs)
                }
                return aryOrderList
            }else{
                return []
            }
        }catch{
            return []
        }
        
        
        
    }
    func getOrderList(withOrderType type:Int, withPageIndex pageIndex:Int) -> [CRMJob]
    {
        let orderFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "OrderDetailTable")
        orderFetchRequest.entity = NSEntityDescription.entity(forEntityName: "OrderDetailTable", in: self.managedObjectContext)
        let sortDescriptor = NSSortDescriptor(key: "o_id", ascending: false)
        orderFetchRequest.sortDescriptors = [sortDescriptor]
        orderFetchRequest.fetchLimit = 10
        orderFetchRequest.fetchOffset = ( (pageIndex - 1 ) * orderFetchRequest.fetchLimit )
        
        if type == 0
        {
            
        }
        else if type == 1
        {
            orderFetchRequest.predicate = NSPredicate(format: "is_schedule = %@ ","0")
        }
        else if type == 2
        {
            orderFetchRequest.predicate = NSPredicate(format: "is_schedule = %@ AND is_ack = %@ AND order_status = %@ ","0","1","0")
        }
        else if type == 3
        {
            
            orderFetchRequest.predicate = NSPredicate(format: " is_schedule != %@ AND is_close == %@ AND is_ack == %@ AND order_status == %@ AND NOT (is_sub_close CONTAINS %@)   ","0","0","1","0","0")
            
        }
        do {
            if let orderFetch = try self.managedObjectContext.fetch(orderFetchRequest) as? [OrderDetailTable]
            {
                var aryOrderList:[CRMJob] = []
                for orderData in orderFetch
                {
                    let objCRMJobs:CRMJob = CRMJob(WithCoreDataObject: orderData)
                    objCRMJobs.photos = self.getPhotoInCoreData(fromOrderId: "0", withOrderItemId: objCRMJobs.o_id, withType: "order")
                    objCRMJobs.videos = self.getVideoInCoreData(fromOrderId: "0", withOrderItemId: objCRMJobs.o_id, withType: "order")
                    objCRMJobs.orderTasks = self.getTask(fromOId: objCRMJobs.o_id)
                    objCRMJobs.orderMattress = self.getMattress(fromOId: objCRMJobs.o_id)
                    
                    aryOrderList.append(objCRMJobs)
                }
                return aryOrderList
            }else{
                return []
            }
        }catch{
            return []
        }
    }
    func getPartDetailsList(withItemId itemId:String, withOrderId orderId:String, withCompanyId companyId:String) -> [CRMPartDetails]
    {
        
        let orderFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "PartsDetails")
        orderFetchRequest.entity = NSEntityDescription.entity(forEntityName: "PartsDetails", in: self.managedObjectContext)
        orderFetchRequest.predicate = NSPredicate(format: "item_id = %@ AND order_id = %@ AND isDeletedPart != 1 ",itemId,orderId)
        let sortDescriptor = NSSortDescriptor(key: "part_id", ascending: false)
        orderFetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            if let partDetailsFetch = try self.managedObjectContext.fetch(orderFetchRequest) as? [PartsDetails]
            {
                var aryPartsList:[CRMPartDetails] = []
                for part in partDetailsFetch
                {
                    let objCRMPartDetails:CRMPartDetails = CRMPartDetails.init(withCoreData: part)
                    
                    aryPartsList.append(objCRMPartDetails)
                }
                return aryPartsList
            }else{
                return []
            }
        }catch{
            return []
        }
    }
    
    func getInvoiceList() -> [CRMInvoices]
    {
        let stateFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Invoice")
        stateFetchRequest.entity = NSEntityDescription.entity(forEntityName: "Invoice", in: self.managedObjectContext)
        do {
            if let invoiceFetch = try self.managedObjectContext.fetch(stateFetchRequest) as? [Invoice]
            {
                var aryInvoice:[CRMInvoices] = []
                for invoice in invoiceFetch{
                    aryInvoice.append(CRMInvoices(WithCoreDataObject: invoice))
                }
                return aryInvoice
            }else{
                return []
            }
        }catch{
            return []
        }
    }
    
    func getLogTalbeCount() -> Int
    {
        let stateFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Log")
        stateFetchRequest.entity = NSEntityDescription.entity(forEntityName: "Log", in: self.managedObjectContext)
        do {
            if let logFetch = try self.managedObjectContext.fetch(stateFetchRequest) as? [Log]
            {
                
                return logFetch.count
            }else{
                return 0
            }
        }catch{
            return 0
        }
    }
    func getPhotoInCoreData(fromOrderId oId:String, withOrderItemId order_Item_Id:String, withType type:String) -> [CRMImage]
    {
        let photoFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Photo")
        photoFetchRequest.entity = NSEntityDescription.entity(forEntityName: "Photo", in: self.managedObjectContext)
        photoFetchRequest.predicate = NSPredicate.init(format: " order_id = %@ AND order_item_id = %@ AND  type = %@ AND isDelete = 0", oId, order_Item_Id,type)
        //AND  order_item_id = '%@' AND  type = '%@' AND isDelete = 0 , order_Item_Id,type
        do {
            if let photoFetch = try self.managedObjectContext.fetch(photoFetchRequest) as? [Photo]
            {
                var aryImages:[CRMImage] = []
                for  image in photoFetch
                {
                    aryImages.append(CRMImage.init(withCoreDataObject: image))
                }
                return aryImages
            }
            else
            {
                return []
            }
        }catch{
            return []
        }
        
    }
    func getVideoInCoreData(fromOrderId oId:String, withOrderItemId order_Item_Id:String, withType type:String) -> [CRMVideo]
    {
        let videoFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Video")
        videoFetchRequest.entity = NSEntityDescription.entity(forEntityName: "Video", in: self.managedObjectContext)
        videoFetchRequest.predicate = NSPredicate.init(format: " order_id = %@ AND  order_item_id = %@ AND  type = %@ AND  isDelete = 0 ", oId, order_Item_Id,type)
        
        do {
            if let videoFetch = try self.managedObjectContext.fetch(videoFetchRequest) as? [Video]
            {
                var aryVideo:[CRMVideo] = []
                for  image in videoFetch
                {
                    aryVideo.append(CRMVideo.init(withCoreDataObject: image))
                }
                return aryVideo
            }
            else
            {
                return []
            }
        }catch{
            return []
        }
        
    }
    
    func getInvoiceDetail(with invoiceID:String) -> [CRMInvoiceOrder]
    {
        
        let stateFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "InvoiceDetail")
        
        stateFetchRequest.entity = NSEntityDescription.entity(forEntityName: "InvoiceDetail", in: self.managedObjectContext)
        
        //        let strId = String (format: "%d",invoiceID)
        stateFetchRequest.predicate = NSPredicate.init(format: "id = %@", invoiceID)
        
        do {
            if let invoiceFetch = try self.managedObjectContext.fetch(stateFetchRequest) as? [InvoiceDetail]
            {
                var aryInvoice:[CRMInvoiceOrder] = []
                for invoice in invoiceFetch{
                    aryInvoice.append(CRMInvoiceOrder(WithCoreDataObject: invoice))
                }
                return aryInvoice
            }else{
                return []
            }
        }catch{
            return []
        }
    }
    
    func getRemainingPhotosForUploading() -> [CRMFileUpload]
    {
        var aryFileUpload:[CRMFileUpload] = []
        
        
        let date:Date = Date()
        //print(date)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        //fetchRequest.predicate = NSPredicate(format: "upload_status = %@ OR upload_status = %@ ",CRMUploadStatus.pending.rawValue,CRMUploadStatus.failed.rawValue)
        fetchRequest.predicate = NSPredicate(format: " upload_status = %@ OR ( upload_status = %@  AND modified_date <= %@ ) ",CRMUploadStatus.pending.rawValue,CRMUploadStatus.failed.rawValue,date as CVarArg)
        
        //fetchRequest.predicate = NSPredicate(format: "upload_status = %@ ",CRMUploadStatus.pending.rawValue)
        do {
            
            if let photoFetch = try self.managedObjectContext.fetch(fetchRequest) as? [Photo]
            {
                
                for  image in photoFetch
                {
                    let objImage:CRMImage = CRMImage.init(withCoreDataObject: image)
                   
                    let fileUploader:CRMFileUpload = CRMFileUpload.init(withImageObject: objImage, withCompanyId: objImage.companyId)
                    aryFileUpload.append(fileUploader)
                    
                }
                //return aryFileUpload
            }
        }
        catch
        {
            //print("Error in photo table")
        }
        let fetchVideoRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Video")
        fetchVideoRequest.predicate = NSPredicate(format: "upload_status = %@ OR ( upload_status = %@ AND modified_date <= %@ ) ",CRMUploadStatus.pending.rawValue,CRMUploadStatus.failed.rawValue, date as CVarArg)
        //fetchVideoRequest.predicate = NSPredicate(format: "upload_status = %@ ",CRMUploadStatus.pending.rawValue)
        do {
            
            if let videoFetch = try self.managedObjectContext.fetch(fetchVideoRequest) as? [Video]
            {
                
                for  video in videoFetch
                {
                    let objVideo:CRMVideo = CRMVideo.init(withCoreDataObject: video)
                    let fileUploader:CRMFileUpload = CRMFileUpload.init(withVideoObject: objVideo, withCompanyId: objVideo.company_id)
                    aryFileUpload.append(fileUploader)
                    
                }
                //return aryFileUpload
            }
            
        }
        catch
        {
            //print("Error in Video");
        }
        return aryFileUpload
        
        
    }
    func getRemainingMediaUploading(forOrderId orderId:String) -> Int
    {
        var aryFileUpload:[CRMFileUpload] = []
        
        
        let date:Date = Date()
        var mediaCount:Int = 0
        //print(date)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        //fetchRequest.predicate = NSPredicate(format: "upload_status = %@ OR upload_status = %@ ",CRMUploadStatus.pending.rawValue,CRMUploadStatus.failed.rawValue)
        fetchRequest.predicate = NSPredicate(format: " order_id = %@ AND ( upload_status = %@ OR ( upload_status = %@  AND modified_date <= %@ ) )",orderId,CRMUploadStatus.pending.rawValue,CRMUploadStatus.failed.rawValue,date as CVarArg)

        do {
            
            if let photoFetch = try self.managedObjectContext.fetch(fetchRequest) as? [Photo]
            {
                
                mediaCount = mediaCount + photoFetch.count
                //return aryFileUpload
            }
        }
        catch
        {
            //print("Error in photo table")
        }
        let fetchVideoRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Video")
        fetchVideoRequest.predicate = NSPredicate(format: " order_id = %@ AND ( upload_status = %@ OR ( upload_status = %@ AND modified_date <= %@ ) ) ",orderId,CRMUploadStatus.pending.rawValue,CRMUploadStatus.failed.rawValue, date as CVarArg)
        //fetchVideoRequest.predicate = NSPredicate(format: "upload_status = %@ ",CRMUploadStatus.pending.rawValue)
        do {
            
            if let videoFetch = try self.managedObjectContext.fetch(fetchVideoRequest) as? [Video]
            {
                
                 mediaCount = mediaCount + videoFetch.count
                //return aryFileUpload
            }
            
        }
        catch
        {
            //print("Error in Video");
        }
        return mediaCount
        
    }
    
    func getSignatureImage(fromOrderId orderId:String) -> CRMImage?
    {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        //fetchRequest.predicate = NSPredicate(format: "upload_status = %@ OR upload_status = %@ ",CRMUploadStatus.pending.rawValue,CRMUploadStatus.failed.rawValue)
        fetchRequest.predicate = NSPredicate(format: " upload_status = %@ AND order_id = %@ AND type = %@ ",CRMUploadStatus.uploaded.rawValue,orderId,"signature")
        
        
        //fetchRequest.predicate = NSPredicate(format: "upload_status = %@ ",CRMUploadStatus.pending.rawValue)
        do {
            
            if let photoFetch = try self.managedObjectContext.fetch(fetchRequest) as? [Photo]
            {
                
                for  image in photoFetch
                {
                    let objImage:CRMImage = CRMImage.init(withCoreDataObject: image)
                    return objImage
                }
                //return aryFileUpload
                
            }
            return nil
        }
        catch
        {
            return nil
            //print("Error in photo table")
        }
        
    }
    
    //GetStateId
    
    
    func getStateId(ForStateId stateName:String) -> Int
    {
        let stateFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "State")
        stateFetchRequest.entity = NSEntityDescription.entity(forEntityName: "State", in: self.managedObjectContext)
        do {
            if let stateFetch = try self.managedObjectContext.fetch(stateFetchRequest) as? [State]
            {
                for index in 0..<stateFetch.count {
                    if stateFetch[index].state_name == stateName {
                        return Int(stateFetch[index].state_id)
                    }else{
                    }
                }
            }
        }catch{
            return -1
        }
        return -1
    }
    
    func getCitieId(ForStateId stateId:Int, ForCityId cityName:String) ->Int
    {
        let cityFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "City")
        cityFetchRequest.entity = NSEntityDescription.entity(forEntityName: "City", in: self.managedObjectContext)
        let stateIdStr = String (format: "%d",stateId)
        cityFetchRequest.predicate = NSPredicate.init(format: "state_id == %@", stateIdStr)
        
        do {
            if let cityFetch = try self.managedObjectContext.fetch(cityFetchRequest) as? [City]
            {
                
                for index in 0..<cityFetch.count {
                    if cityFetch[index].city_name == cityName {
                        return Int(cityFetch[index].state_id)
                    }else{
                    }
                }
            }else{
                return -1
            }
        }catch{
            return -1
        }
        return -1
    }
    
    
    
    
    
    func getItemConditionList() -> [CRMItemCondition]
    {
        let itemConditionFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Item_condition")
        itemConditionFetchRequest.entity = NSEntityDescription.entity(forEntityName: "Item_condition", in: self.managedObjectContext)
        
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        itemConditionFetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            
            if let itemCauseFetch = try self.managedObjectContext.fetch(itemConditionFetchRequest) as? [Item_condition]
            {
                var aryItemCondition:[CRMItemCondition] = []
                for itemCondition in itemCauseFetch
                {
                    aryItemCondition.append(CRMItemCondition(withCoreDataObject: itemCondition))
                }
                return aryItemCondition
            }else{
                return []
            }
        }catch{
            return []
        }
    }
    
    
    
    func getStateName(ForStateId stateId:Int) -> String
    {
        let stateFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "State")
        stateFetchRequest.entity = NSEntityDescription.entity(forEntityName: "State", in: self.managedObjectContext)
        do {
            if let stateFetch = try self.managedObjectContext.fetch(stateFetchRequest) as? [State]
            {
                for index in 0..<stateFetch.count {
                    if stateFetch[index].state_id == Int64(stateId) {
                        return stateFetch[index].state_name!
                        
                    }else{
                    }
                }
            }
        }catch{
            return ""
        }
        return ""
    }
    
    
    func getCitieName(ForStateId stateId:Int, ForCityId cityId:String) ->String {
        let cityFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "City")
        cityFetchRequest.entity = NSEntityDescription.entity(forEntityName: "City", in: self.managedObjectContext)
        let stateIdStr = String (format: "%d",stateId)
        cityFetchRequest.predicate = NSPredicate.init(format: "state_id = %@ AND city_id = %@", stateIdStr,cityId)
        do {
            if let cityFetch = try self.managedObjectContext.fetch(cityFetchRequest) as? [City]
            {
                
                for index in 0..<cityFetch.count {
                    
                    if cityFetch[index].city_id == Int64(cityId) {
                        //////print(cityFetch[index].city_name ?? "")
                        return cityFetch[index].city_name!
                    }
                }
            }else{
                return ""
            }
        }catch{
            return ""
        }
        return ""
    }
    
    
    
    func getServiceStatus(ForStatusId statusId:String) -> CRMServicesStatus?
    {
        let serviceStatusFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Service_status")
        serviceStatusFetchRequest.predicate = NSPredicate.init(format: "id == %@", statusId)
        serviceStatusFetchRequest.entity = NSEntityDescription.entity(forEntityName: "Service_status", in: self.managedObjectContext)
        do {
            
            if let serviceStatusFetch = try self.managedObjectContext.fetch(serviceStatusFetchRequest) as? [Service_status]
            {
                var servicesStatusValue:CRMServicesStatus?
                for serviceStatus in serviceStatusFetch
                {
                    servicesStatusValue = CRMServicesStatus(withCoreDataObject: serviceStatus)
                }
                return servicesStatusValue
            }else{
                return nil
            }
        }catch{
            return nil
        }
    }
    
    func getServiceStatusList(withCompanyId companyId:String) -> [CRMServicesStatus]
    {
        let serviceStatusFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Service_status")
        serviceStatusFetchRequest.entity = NSEntityDescription.entity(forEntityName: "Service_status", in: self.managedObjectContext)
        serviceStatusFetchRequest.predicate = NSPredicate.init(format: "company_id = %@",companyId)
        
        let sortDescriptor = NSSortDescriptor(key: "status_name", ascending: true)
        serviceStatusFetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            
            if let serviceStatusFetch = try self.managedObjectContext.fetch(serviceStatusFetchRequest) as? [Service_status]
            {
                var aryServicesStatus:[CRMServicesStatus] = []
                for serviceStatus in serviceStatusFetch
                {
                    aryServicesStatus.append(CRMServicesStatus(withCoreDataObject: serviceStatus))
                }
                return aryServicesStatus
            }else{
                return []
            }
        }catch{
            return []
        }
    }
    func getServiceStatusList() -> [CRMServicesStatus]
    {
        let serviceStatusFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Service_status")
        serviceStatusFetchRequest.entity = NSEntityDescription.entity(forEntityName: "Service_status", in: self.managedObjectContext)
        let sortDescriptor = NSSortDescriptor(key: "status_name", ascending: true)
        serviceStatusFetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            
            if let serviceStatusFetch = try self.managedObjectContext.fetch(serviceStatusFetchRequest) as? [Service_status]
            {
                var aryServicesStatus:[CRMServicesStatus] = []
                for serviceStatus in serviceStatusFetch
                {
                    aryServicesStatus.append(CRMServicesStatus(withCoreDataObject: serviceStatus))
                }
                return aryServicesStatus
            }else{
                return []
            }
        }catch{
            return []
        }
    }
    func getServiceDataList() -> [CRMServicesData]
    {
        let servicesDataFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "ServicesData")
        servicesDataFetchRequest.entity = NSEntityDescription.entity(forEntityName: "ServicesData", in: self.managedObjectContext)
        
        let sortDescriptor = NSSortDescriptor(key: "modified", ascending: false)
        servicesDataFetchRequest.sortDescriptors = [sortDescriptor]
        do {
            
            if let serviceDataFetch = try self.managedObjectContext.fetch(servicesDataFetchRequest) as? [ServicesData]
            {
                var aryServicesData:[CRMServicesData] = []
                for servicesData in serviceDataFetch
                {
                    aryServicesData.append(CRMServicesData(withCoreDataObject: servicesData))
                }
                return aryServicesData
            }else{
                return []
            }
        }catch{
            return []
        }
    }
    func getUsersList() -> [CRMTableUsersData]
    {
        let usersFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Users")
        usersFetchRequest.entity = NSEntityDescription.entity(forEntityName: "Users", in: self.managedObjectContext)
        
        
        do {
            if let serviceDataFetch = try self.managedObjectContext.fetch(usersFetchRequest) as? [Users]
            {
                var aryUsersData:[CRMTableUsersData] = []
                for users in serviceDataFetch
                {
                    aryUsersData.append(CRMTableUsersData(withCoreDataObject: users))
                }
                return aryUsersData
            }else{
                return []
            }
        }catch{
            return []
        }
    }
    func getOrderDetails(fromOId oId:String) -> CRMJob?
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "OrderDetailTable")
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "OrderDetailTable", in: self.managedObjectContext)
        
        fetchRequest.predicate = NSPredicate(format: "o_id = %@", oId)
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as? [OrderDetailTable]
            for order in records!
            {
                let objCRMJob:CRMJob = CRMJob.init(WithCoreDataObject: order)
                //objCRMJob.photos = self.getPhoto(fromOId: "0", withOrderItemId: objCRMJob.o_id, withType: "order")
                //objCRMJob.videos = self.getVideo(fromOId:"0", withOrderItemId: objCRMJob.o_id, withType: "order")
                objCRMJob.photos = self.getPhotoInCoreData(fromOrderId: "0", withOrderItemId: objCRMJob.o_id, withType: "order")
                objCRMJob.videos = self.getVideoInCoreData(fromOrderId: "0", withOrderItemId:  objCRMJob.o_id, withType: "order")
                objCRMJob.orderTasks = self.getTask(fromOId: objCRMJob.o_id)
                objCRMJob.orderMattress = self.getMattress(fromOId: objCRMJob.o_id)
                return objCRMJob
            }
        } catch
        {
            return nil
        }
        return nil
    }
    /*
     func getPhoto(fromOId oId:String, withOrderItemId orderItemId:String, withType type:String) -> [CRMImage]
     {
     let fetchPhotoRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Photo")
     ////print(fetchPhotoRequest)
     fetchPhotoRequest.entity = NSEntityDescription.entity(forEntityName: "Photo", in: self.managedObjectContext)
     fetchPhotoRequest.predicate = NSPredicate(format: "order_id = %@ AND order_item_id = %@ AND type = %@", oId,orderItemId,type)
     
     do {
     
     if let serviceStatusFetch = try self.managedObjectContext.fetch(fetchPhotoRequest) as? [Photo]
     {
     var aryPhoto:[CRMImage] = []
     for photo in serviceStatusFetch
     {
     let objImage:CRMImage = CRMImage.init(withCoreDataObject: photo)
     aryPhoto.append(objImage)
     }
     return aryPhoto
     
     
     }else{
     return []
     }
     }catch{
     return []
     }
     
     }
     func getVideo(fromOId oId:String, withOrderItemId orderItemId:String, withType type:String) -> [CRMVideo]
     {
     let fetchVideoRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Video")
     ////print(fetchVideoRequest)
     fetchVideoRequest.entity = NSEntityDescription.entity(forEntityName: "Video", in: self.managedObjectContext)
     fetchVideoRequest.predicate = NSPredicate(format: "order_id = %@ AND order_item_id = %@ AND type = %@", oId,orderItemId,type)
     
     do {
     
     if let serviceStatusFetch = try self.managedObjectContext.fetch(fetchVideoRequest) as? [Video]
     {
     var aryVideo:[CRMVideo] = []
     
     for video in serviceStatusFetch
     {
     let objVideo:CRMVideo = CRMVideo.init(withCoreDataObject: video)
     aryVideo.append(objVideo)
     }
     return aryVideo
     
     
     }else{
     return []
     }
     }catch{
     return []
     }
     }
     */
    func getTask(fromOId oId:String) -> [CRMTask]
    {
        let fetchTaskRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Task")
        
        fetchTaskRequest.entity = NSEntityDescription.entity(forEntityName: "Task", in: self.managedObjectContext)
        fetchTaskRequest.predicate = NSPredicate(format: "order_id = %@ ", oId)
        
        do {
            
            if let serviceStatusFetch = try self.managedObjectContext.fetch(fetchTaskRequest) as? [Task]
            {
                var aryTask:[CRMTask] = []
                
                for task in serviceStatusFetch
                {
                    let objTask:CRMTask = CRMTask.init(withCoreDataObject: task)
                    objTask.aryImages = self.getPhotoInCoreData(fromOrderId: objTask.orderId, withOrderItemId: objTask.itemId, withType: "item")
                    objTask.aryVideos = self.getVideoInCoreData(fromOrderId: objTask.orderId, withOrderItemId:  objTask.itemId, withType: "item")
                    aryTask.append(objTask)
                    
                }
                return aryTask
                
                
            }else{
                return []
            }
        }catch{
            return []
        }
    }
    func getMattress(fromOId oId:String) -> [CRMMattress]
    {
        let fetchMattressRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Mettress")
        
        fetchMattressRequest.entity = NSEntityDescription.entity(forEntityName: "Mettress", in: self.managedObjectContext)
        fetchMattressRequest.predicate = NSPredicate(format: "order_id = %@ ", oId)
        
        do {
            
            if let serviceStatusFetch = try self.managedObjectContext.fetch(fetchMattressRequest) as? [Mettress]
            {
                var aryMattress:[CRMMattress] = []
                
                for mattress in serviceStatusFetch
                {
                    let objMattress:CRMMattress = CRMMattress.init(withCoreDataObject: mattress)
                    objMattress.aryImages = self.getPhotoInCoreData(fromOrderId: objMattress.orderId, withOrderItemId: objMattress.mattressId, withType: "mattress")
                    objMattress.aryVideos = self.getVideoInCoreData(fromOrderId: objMattress.orderId, withOrderItemId:  objMattress.mattressId, withType: "mattress")
                    
                    aryMattress.append(objMattress)
                    
                }
                return aryMattress
                
                
            }else{
                return []
            }
        }catch{
            return []
        }
    }
    
    func getTaskDetails(fromItemId itemId:String) -> CRMTask?
    {
        let fetchTaskRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Task")
        
        fetchTaskRequest.entity = NSEntityDescription.entity(forEntityName: "Task", in: self.managedObjectContext)
        fetchTaskRequest.predicate = NSPredicate(format: "item_id = %@ ", itemId)
        
        do {
            
            if let serviceStatusFetch = try self.managedObjectContext.fetch(fetchTaskRequest) as? [Task]
            {
                for task in serviceStatusFetch
                {
                    let objTask:CRMTask = CRMTask.init(withCoreDataObject: task)
                    objTask.aryImages = self.getPhotoInCoreData(fromOrderId: objTask.orderId, withOrderItemId: objTask.itemId, withType: "item")
                    objTask.aryVideos = self.getVideoInCoreData(fromOrderId: objTask.orderId, withOrderItemId:  objTask.itemId, withType: "item")
                    return objTask
                    
                }
                return nil
            }else{
                return nil
            }
        }
        catch
        {
            return nil
        }
    }
    func getMattressDetails(fromMattressId mattressId:String) -> CRMMattress?
    {
        let fetchTaskRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Mettress")
        
        fetchTaskRequest.entity = NSEntityDescription.entity(forEntityName: "Mettress", in: self.managedObjectContext)
        fetchTaskRequest.predicate = NSPredicate(format: "matter_id = %@ ", mattressId)
        
        do {
            
            if let serviceStatusFetch = try self.managedObjectContext.fetch(fetchTaskRequest) as? [Mettress]
            {
                for task in serviceStatusFetch
                {
                    let objMattress:CRMMattress = CRMMattress.init(withCoreDataObject: task)
                    objMattress.aryImages = self.getPhotoInCoreData(fromOrderId: objMattress.orderId, withOrderItemId: objMattress.mattressId, withType: "mattress")
                    objMattress.aryVideos = self.getVideoInCoreData(fromOrderId: objMattress.orderId, withOrderItemId:  objMattress.mattressId, withType: "mattress")
                    return objMattress
                    
                }
                return nil
            }else{
                return nil
            }
        }
        catch
        {
            return nil
        }
    }
    func getCalenderCount(withStartDate startDate:String, withEndDate endDate:String) -> [NSDictionary]
    {
        let orderFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "OrderDetailTable")
        orderFetchRequest.entity = NSEntityDescription.entity(forEntityName: "OrderDetailTable", in: self.managedObjectContext)
        
        //        let sortDescriptor = NSSortDescriptor(key: "o_id", ascending: false)
        //        orderFetchRequest.sortDescriptors = [sortDescriptor]
        
        let emailExpr = NSExpression.init(forKeyPath: "apntmnt_date");
        let countExpr = NSExpression.init(forFunction: "count:", arguments: [emailExpr])
        
        let sumED = NSExpressionDescription()
        sumED.expression = countExpr
        sumED.name = "count"
        sumED.expressionResultType = .integer32AttributeType
        
        orderFetchRequest.propertiesToFetch = ["apntmnt_date", sumED ]
        orderFetchRequest.propertiesToGroupBy = ["apntmnt_date"]
        orderFetchRequest.resultType = .dictionaryResultType
        
        let predicate = NSPredicate(format: "apntmnt_date >= %@ AND apntmnt_date <= %@ ",startDate,endDate)
        orderFetchRequest.predicate = predicate
        var aryCalenderCount:[NSDictionary] = []
        
        do {
            if let orderFetch = try self.managedObjectContext.fetch(orderFetchRequest) as? [NSDictionary]
            {
                for order in orderFetch
                {
                    var dictDescription:[String:Any] = [:]
                    if let value = order.value(forKey: "apntmnt_date")
                    {
                        dictDescription["apntmnt_date"] = value
                    }
                    if let value = order.value(forKey: "count")
                    {
                        dictDescription["count"] = "\(value)"
                    }
                    aryCalenderCount.append(dictDescription as NSDictionary)
                }
                return aryCalenderCount
            }
            else
            {
                //   return 0
                ////print("Something wrong1 \(try self.managedObjectContext.fetch(orderFetchRequest) as? [NSManagedObject])")
                return aryCalenderCount
            }
        }catch
        {
            ////print("Something wrong2")
            // return 0
            return aryCalenderCount
        }
        
    }
    func getOrderListTotalCount(withType type:Int) -> Int
    {
        let orderFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "OrderDetailTable")
        orderFetchRequest.entity = NSEntityDescription.entity(forEntityName: "OrderDetailTable", in: self.managedObjectContext)
        let sortDescriptor = NSSortDescriptor(key: "o_id", ascending: false)
        orderFetchRequest.sortDescriptors = [sortDescriptor]
        
        if type == 0
        {
            
        }
        else if type == 1
        {
            orderFetchRequest.predicate = NSPredicate(format: "is_schedule = 0")
        }
        else if type == 2
        {
            orderFetchRequest.predicate = NSPredicate(format: "is_schedule = 0 AND is_ack = 1 AND order_status = 0")
        }
        else if type == 3
        {
            orderFetchRequest.predicate = NSPredicate(format: "is_schedule != 0 AND is_close = 0 AND is_ack = 1 AND order_status = 0 AND is_sub_close !=0")
        }
        do {
            if let orderFetch = try self.managedObjectContext.fetch(orderFetchRequest) as? [OrderDetailTable]
            {
                
                return orderFetch.count
            }else{
                return 0
            }
        }catch{
            return 0
        }
        
    }
    func getCalenderOrderList(fromDate date:String) -> [CRMJob]
    {
        let orderFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "OrderDetailTable")
        orderFetchRequest.entity = NSEntityDescription.entity(forEntityName: "OrderDetailTable", in: self.managedObjectContext)
        
        let sortDescriptor = NSSortDescriptor(key: "o_id", ascending: false)
        orderFetchRequest.sortDescriptors = [sortDescriptor]
        
        let predicate = NSPredicate(format: "apntmnt_date == %@ ",date)
        orderFetchRequest.predicate = predicate
        //var aryCalenderCount:[CRMJob] = []
        
        do {
            if let orderFetch = try self.managedObjectContext.fetch(orderFetchRequest) as? [OrderDetailTable]
            {
                var aryOrderList:[CRMJob] = []
                for orderData in orderFetch
                {
                    let objCRMJobs:CRMJob = CRMJob(WithCoreDataObject: orderData)
                    objCRMJobs.photos = self.getPhotoInCoreData(fromOrderId: "0", withOrderItemId: objCRMJobs.o_id, withType: "order")
                    objCRMJobs.videos = self.getVideoInCoreData(fromOrderId: "0", withOrderItemId: objCRMJobs.o_id, withType: "order")
                    objCRMJobs.orderTasks = self.getTask(fromOId: objCRMJobs.o_id)
                    objCRMJobs.orderMattress = self.getMattress(fromOId: objCRMJobs.o_id)
                    
                    aryOrderList.append(objCRMJobs)
                }
                return aryOrderList
            }else{
                return []
            }
            
        }catch
        {
            
            // return 0
            return []
        }
        
    }
    
    //MARK:- Validation Record
    
    
    func checkImageAddedInOrder(fromOrderId orderId:String) -> Bool
    {
        var isImageAvailable:Bool = false
        
        let orderTasks:[CRMTask] = self.getTask(fromOId: orderId)
        for task in orderTasks
        {
            
            //Condition for no photos check 
            //Date:- 3/9/2017
//            if task.aryImages.count > 0
//            {
//                isImageAvailable = true
//                break;
//            }
            
            ////Condition for one photos
            for image in task.aryImages
            {
                if image.imageId != 0
                {
                    isImageAvailable = true
                    break;
                }
            }
            if isImageAvailable == true
            {
                break;
            }
            
        }
        
        if isImageAvailable == false
        {
            let orderTasks:[CRMMattress] = self.getMattress(fromOId: orderId)
            for task in orderTasks
            {
                //Date:- 3/9/2017
//                if task.aryImages.count > 0
//                {
//                    isImageAvailable = true
//                    break;
//                }
                for image in task.aryImages
                {
                    if image.imageId != 0
                    {
                        isImageAvailable = true
                        break;
                    }
                }
                
                if isImageAvailable == true
                {
                    break;
                }
            }
        }
        
        
        return isImageAvailable;
    }
    func checkImageAddedInOrderForMattress(fromOrderId orderId:String) -> Bool
    {
        var isImageAvailable:Bool = false
        
        let orderTasks:[CRMMattress] = self.getMattress(fromOId: orderId)
        for task in orderTasks
        {
            for image in task.aryImages
            {
                if image.imageId != 0
                {
                    isImageAvailable = true
                    break;
                }
            }
            
            if isImageAvailable == true
            {
                break;
            }
        }
        
        return isImageAvailable;
    }
    
    func checkSubTechnicianExistInCoreData(fromUserId userId:String) -> Bool
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SubTechnician")
        fetchRequest.predicate = NSPredicate(format: "user_id = %@", userId)
        
        do {
            
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            if records.count > 0
            {
                return false
            }
            else
            {
                return true
            }
            
        } catch
        {
            return false
        }
        
    }
    
    func checkOrderDetailTableExistInCoreData(fromOId oId:String) -> ( isRecordAvailable:Bool,objCoreDataOrderDetail:OrderDetailTable?)
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderDetailTable")
        fetchRequest.predicate = NSPredicate(format: "o_id = %@", oId)
        
        do {
            
            let records = try managedObjectContext.fetch(fetchRequest) as? [OrderDetailTable]
            if (records?.count)! > 0
            {
                return (true,records?.first)
                
            }
            else
            {
                return (false,nil)
            }
            
        } catch
        {
            return (false,nil)
        }
        
    }
    func checkTaskTableExistInCoreData(fromOId itemId:String) -> ( isRecordAvailable:Bool,objCoreDataTask:Task?)
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "item_id = %@", itemId)
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as? [Task]
            if (records?.count)! > 0
            {
                return (true,records!.first)
                
            }
            else
            {
                return (false,nil)
            }
        } catch
        {
            return (false,nil)
        }
    }
    
    //Urvish
    func checkMattressTableExistInCoreData(fromOId mattressId:String) -> ( isRecordAvailable:Bool,objCoreDataTask:Mettress?)
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Mettress")
        fetchRequest.predicate = NSPredicate(format: "matter_id = %@", mattressId)
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as? [Mettress]
            if (records?.count)! > 0
            {
                return (true,records!.first)
                
            }
            else
            {
                return (false,nil)
            }
        } catch
        {
            return (false,nil)
        }
    }
    
    
    func checkInvoicesExistInCoreData(fromUserId userId:String) -> Bool
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Invoice")
        fetchRequest.predicate = NSPredicate(format: "id = %@", userId)
        
        do {
            
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            if records.count > 0
            {
                return false
            }
            else
            {
                return true
            }
            
        } catch
        {
            return false
        }
        
    }
    
    
    func checkInvoiceDetailExistInCoreData(fromUserId userId:String, oId:String) -> Bool
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "InvoiceDetail")
        fetchRequest.predicate = NSPredicate(format: "id = %@ AND oid = %@", userId ,oId )
        
        do {
            
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            if records.count > 0
            {
                return false
            }
            else
            {
                return true
            }
            
        } catch
        {
            return false
        }
        
    }
    
    func checkOrderStatusInCoreData(fromOrderId oId:String) -> Bool
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "OrderDetailTable")
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "OrderDetailTable", in: self.managedObjectContext)
        fetchRequest.predicate = NSPredicate(format: "o_id = %@", oId)
        
        do {
            
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            if records.count > 0
            {
                return false
            }
            else
            {
                return true
            }
            
        } catch
        {
            return false
        }
        
    }
    func checkSeeLogsInCoreData(fromOrderId id:String) -> Bool
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "SeeLog")
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "SeeLog", in: self.managedObjectContext)
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        
        do {
            
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            if records.count > 0
            {
                return false
            }
            else
            {
                return true
            }
            
        } catch
        {
            return false
        }
        
    }
    func checkPhotoAvailableInCoreData(fromPId pId:String) -> Bool
    {
        var isSucess:Bool = false
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "p_id = %@", pId)
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            if records.count > 0
            {
                isSucess = true
            }
            else
            {
                isSucess = false
            }
            
        }
        catch {
            isSucess = false
            ////print(error)
        }
        return isSucess
    }
    func checkPhotoAvailableInCoreData(fromLocalFilePath locatlPath:String,withItemId itemId:String,withOrderId orderId:String) -> Bool
    {
        var isSucess:Bool = false
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "localFileUrl = %@ AND order_item_id = %@ AND order_id = %@", locatlPath,itemId,orderId)
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            if records.count > 0
            {
                isSucess = true
            }
            else
            {
                isSucess = false
            }
            
        }
        catch {
            isSucess = false
            ////print(error)
        }
        return isSucess
    }
    
    func checkVideoAvailableInCoreData(fromVId vId:String) -> Bool
    {
        var isSucess:Bool = false
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Video")
        fetchRequest.predicate = NSPredicate(format: "v_id = %@", vId)
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            if records.count > 0
            {
                isSucess = true
            }
            else
            {
                isSucess = false
            }
            
        }
        catch {
            isSucess = false
            ////print(error)
        }
        
        return isSucess
    }
    func checkVideoAvailableInCoreData(fromVideoLocalFilePath locatlPath:String,withItemId itemId:String,withOrderId orderId:String) -> Bool
    {
        var isSucess:Bool = false
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Video")
        fetchRequest.predicate = NSPredicate(format: "localFileUrl = %@ AND order_id = %@ AND order_item_id = %@", locatlPath,itemId,orderId)
        
        do
        {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            if records.count > 0
            {
                isSucess = true
            }
            else
            {
                isSucess = false
            }
        }
        catch {
            isSucess = false
            ////print(error)
        }
        
        return isSucess
    }
    
    func checkPartsDetailsAvailableInCoreData(fromPartId partId:String) -> ( isRecordAvailable:Bool,objCoreDataPartDetails:PartsDetails?)
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PartsDetails")
        fetchRequest.predicate = NSPredicate(format: "part_id = %@", partId)
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [PartsDetails]
            if records.count > 0
            {
                return (true,records.first)
            }
            else
            {
                return (false,nil)
            }
            
        }
        catch {
            return (false,nil)
            ////print(error)
        }
        //return isSucess
    }
    func checkRescheduleReasonAvailableInCoreData(fromId id:String) -> Bool
    {
        var isSucess:Bool = false
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RescheduleReasons")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            if records.count > 0
            {
                isSucess = true
            }
            else
            {
                isSucess = false
            }
            
        }
        catch {
            isSucess = false
            ////print(error)
        }
        
        return isSucess
    }
    func checkLateReasonAvailableInCoreData(fromId id:String) -> Bool
    {
        var isSucess:Bool = false
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LateScheduleReason")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            if records.count > 0
            {
                isSucess = true
            }
            else
            {
                isSucess = false
            }
            
        }
        catch {
            isSucess = false
            ////print(error)
        }
        
        return isSucess
    }
    
    func checkSubItemCauseAvailableInCoreData(fromId id:String) -> Bool
    {
        var isSucess:Bool = false
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SubItemCause")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            if records.count > 0
            {
                isSucess = true
            }
            else
            {
                isSucess = false
            }
            
        }
        catch {
            isSucess = false
            ////print(error)
        }
        
        return isSucess
    }
    
    
    //MARK:- Update
    func updatePartsDetailsInCoreData(withPartObject objPart:CRMPartDetails, withIsModifyStatus status:Bool, withModifyDate modifyDate:Date) -> Void
    {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PartsDetails")
        if objPart.part_id.characters.count > 0
        {
            fetchRequest.predicate = NSPredicate(format: "part_id = %@ ", objPart.part_id)
        }
        else
        {
            if objPart.createdDate != nil
            {
                //let strDate:String = ((objImage.createdDate?.convertDateInString(withDateFormat: Constant.DateFormat.FullDateTimeTimezone, withConvertedDateFormat: Constant.DateFormat.FullDateTimeTimezone)))!
                let date:Date = objPart.createdDate!
                
                fetchRequest.predicate = NSPredicate(format: "createdDate == %@ AND part_detail = %@ ", date as CVarArg,objPart.part_detail )
            }
        }
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [PartsDetails]
            
            for record in records
            {
                record.item_id = objPart.item_id
                record.order_id = objPart.order_id
                record.user_id = objPart.user_id
                record.company_id = objPart.company_id
                record.date_ordered = objPart.date_ordered
                record.vendor_confm = objPart.vendor_confm
                record.part_detail = objPart.part_detail
                record.part_defect = objPart.part_defect
                record.cost = objPart.cost
                record.shipping_amt = objPart.shipping_amt
                record.first_name = objPart.first_name
                record.last_name = objPart.last_name;
                record.company = objPart.company;
                record.address1 = objPart.address1;
                record.address2 = objPart.address2;
                record.city = objPart.city;
                record.state = objPart.state;
                record.zipcode = objPart.zipcode;
                record.memo = objPart.memo;
                record.createdDate = objPart.createdDate as NSDate?
                record.modifiedDate = modifyDate as NSDate?;
                record.upload_status = String(status);
                record.part_id = objPart.part_id;
                record.upload_pdf = objPart.upload_pdf;
                record.part_status = objPart.part_status;
                record.status_date = objPart.status_date;
                record.status = objPart.status;
                record.isDeletedPart = objPart.isDeletePart
                do
                {
                    try record.managedObjectContext?.save()
                }catch{
                    ////print("Failed to save city object :: At Index = \(index)")
                }
                
            }
            
        } catch {
            ////print(error)
        }
        
    }
    
    func updateTechnicianStatusInCoreData(fromUserId userId:String) -> CRMSubTechnician?
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SubTechnician")
        fetchRequest.predicate = NSPredicate(format: "user_id = %@", userId)
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            
            for record in records {
                
                if (record.value(forKey: "status") as? Int16) != nil
                {
                    var status:Int16 = record.value(forKey: "status") as! Int16
                    if status == 0
                    {
                        status = 1
                    }
                    else
                    {
                        status = 0
                    }
                    record.setValue(NSNumber.init(value: status), forKey: "status")
                }
                record.setValue(NSNumber.init(value: true), forKey: "isModify")
                record.setValue(Date(), forKey: "modifyDate")
                
                
                /// add the log in LogTable
                
                do{
                    try record.managedObjectContext?.save()
                    let objSubTechnician:CRMSubTechnician = CRMSubTechnician.init(WithCoreDataObject: record as! SubTechnician)
                    return objSubTechnician
                    
                }catch{
                    ////print("Failed to save city object :: At Index = \(index)")
                    return nil
                }
                
            }
            return nil
        }
        catch {
            ////print(error)
            return nil
        }
    }
    
    func updateSubTechnicianDetails(withSubTechnician objSubTechnician:CRMSubTechnician, withIsModifyStatus status:Bool, withModifyDate modifyDate:Date, withAddLog isAddLog:Bool
        ) -> Void
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SubTechnician")
        fetchRequest.predicate = NSPredicate(format: "user_id = %@", objSubTechnician.userID)
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            
            for record in records
            {
                record.setValue(objSubTechnician.firstName, forKey: "fname")
                record.setValue(objSubTechnician.lastName, forKey: "lname")
                record.setValue(objSubTechnician.address1, forKey: "address1")
                record.setValue(objSubTechnician.address2, forKey: "address2")
                record.setValue(objSubTechnician.fax, forKey: "fax")
                record.setValue(objSubTechnician.phonenumber, forKey: "phonenumber")
                record.setValue(objSubTechnician.mobile, forKey: "mobile")
                record.setValue(NSNumber.init(value: status), forKey: "isModify")
                record.setValue(modifyDate, forKey: "modifyDate")
                
                if isAddLog == true
                {
                    ///Add the log
                }
                do{
                    try record.managedObjectContext?.save()
                }catch{
                    ////print("Failed to save city object :: At Index = \(index)")
                }
                
            }
            
        } catch {
            ////print(error)
        }
        
    }
    
    func updateTask(withTaskObject objTask:CRMTask, withIsModifyStatus status:Bool, withModifyDate modifyDate:Date) -> Void
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "item_id = %@ ", objTask.itemId)
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            
            for record in records
            {
                record.setValue(objTask.SN_ID_ACK, forKey: "ack")
                record.setValue(objTask.additionalInfo, forKey: "additional_info")
                
                record.setValue("\(objTask.cause.id)", forKey: "cause")
                record.setValue("\(objTask.subCause.id)", forKey: "cause_reason")
                record.setValue(objTask.reasonOfCause, forKey: "other_cause_reason")
                record.setValue(objTask.companyId, forKey: "company_id")
                record.setValue("\(objTask.condition.id)", forKey: "condition")
                if objTask.created.characters.count > 0
                {
                    if objTask.created.getDate(withDateFormate: "yyyy-MM-dd HH:mm:ss") != nil
                    {
                        let value:Date = objTask.created.getDate(withDateFormate: "yyyy-MM-dd HH:mm:ss")!
                        
                        record.setValue(value, forKey: "created_date")
                    }
                    
                }
                
                record.setValue(objTask.creatorId, forKey: "creator_id")
                record.setValue(objTask.deleteStatus, forKey: "delete_status")
                record.setValue(objTask.estimatedOnlyPrice, forKey: "estimate_only_price")
                record.setValue(objTask.itemId, forKey: "item_id")
                record.setValue(objTask.itemPhotos, forKey: "item_photos")
                record.setValue(objTask.itemNo, forKey: "itm_no")
                record.setValue(objTask.MFG_Date, forKey: "mfg_date")
                record.setValue(objTask.model, forKey: "model")
                //record.setValue(objTask.modified, forKey: "modified_date")
                record.setValue(objTask.orderId, forKey: "order_id")
                record.setValue(objTask.partConfirmation, forKey: "part_confirmation")
                
                if objTask.partNeed.count > 0
                {
                    record.setValue(objTask.partNeed[0], forKey: "parts_needed1")
                }
                if objTask.partNeed.count > 1
                {
                    record.setValue(objTask.partNeed[1], forKey: "parts_needed2")
                }
                if objTask.partNeed.count > 2
                {
                    record.setValue(objTask.partNeed[2], forKey: "parts_needed3")
                }
                if objTask.partNeed.count > 3
                {
                    record.setValue( objTask.partNeed[3], forKey: "parts_needed4")
                }
                record.setValue(objTask.retailPrice, forKey: "retail_price")
                record.setValue(objTask.revisedComments, forKey: "revised_comments")
                record.setValue("\(objTask.taskType.id)", forKey: "service_type")
                record.setValue("\(objTask.status.id)", forKey: "status")
                record.setValue(objTask.style, forKey: "style")
                record.setValue(objTask.techServiceItemDate, forKey: "tech_service_item_date")
                record.setValue(objTask.techComments, forKey: "technician_comment")
                record.setValue(objTask.title, forKey: "title")
                record.setValue(objTask.vendor.user_id, forKey: "vendor_id")
                record.setValue(objTask.company, forKey: "company")
                record.setValue(NSNumber.init(value: status), forKey: "isModify")
                record.setValue(modifyDate, forKey: "modified_date")
                
                self.updateTaskPhotosInCoreData(fromTaskObject: objTask)
                self.updateTaskVideosInCoreData(fromTaskObject: objTask)
                
                do
                {
                    try record.managedObjectContext?.save()
                }catch{
                    ////print("Failed to save city object :: At Index = \(index)")
                }
                
            }
            
        } catch {
            ////print(error)
        }
        
    }
    func updateTaskAfterSyncing(withTaskId itemId:String, withIsModifyStatus status:Bool, withModifyDate modifyDate:Date) -> Void
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "item_id = %@ ", itemId)
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            
            for record in records
            {
                
                record.setValue(NSNumber.init(value: status), forKey: "isModify")
                record.setValue(modifyDate, forKey: "modified_date")
                
                do
                {
                    try record.managedObjectContext?.save()
                }catch{
                    ////print("Failed to save city object :: At Index = \(index)")
                }
                
            }
            
        } catch {
            ////print(error)
        }
        
    }
    func updateMattress(withMattressObject objMattress:CRMMattress, withIsModifyStatus status:Bool, withModifyDate modifyDate:Date) -> Void
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Mettress")
        fetchRequest.predicate = NSPredicate(format: "matter_id = %@ ", objMattress.mattressId)
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            
            for record in records
            {
                record.setValue(objMattress.mattressHaveDamage, forKey: "any_damage")
                record.setValue(objMattress.box, forKey: "box")
                record.setValue(objMattress.boxReport, forKey: "box_description")
                record.setValue("\(objMattress.cause.id)", forKey: "cause")
                record.setValue("\(objMattress.subCause.id)", forKey: "cause_reason")
                record.setValue(objMattress.reasonOfCause, forKey: "other_cause_reason")
                record.setValue(objMattress.companyId, forKey: "company_id")
                record.setValue(objMattress.creatorId, forKey: "creator_id")
                if objMattress.createdDate.characters.count > 0
                {
                    if objMattress.createdDate.getDate(withDateFormate: "yyyy-MM-dd HH:mm:ss") != nil
                    {
                        let value:Date = objMattress.createdDate.getDate(withDateFormate: "yyyy-MM-dd HH:mm:ss")!
                        record.setValue(value, forKey: "created_date")
                    }
                }
                record.setValue(objMattress.deleteStatus, forKey: "delete_status")
                record.setValue(objMattress.strDescription, forKey: "description_title")
                record.setValue(objMattress.firmness, forKey: "firmness")
                record.setValue(objMattress.frameType, forKey: "frame_type")
                record.setValue(objMattress.frameWithSlate, forKey: "frame_slats")
                record.setValue(objMattress.frameReport, forKey: "frame_description")
                record.setValue(objMattress.mattressHaveStains, forKey: "have_stains")
                record.setValue(objMattress.labelName, forKey: "label_name")
                record.setValue(objMattress.labelCode, forKey: "label_code")
                record.setValue(objMattress.manufacturer, forKey: "manufacturer")
                record.setValue(objMattress.mattressDOB, forKey: "mat_box_mfg")
                record.setValue(objMattress.firmnessOther, forKey: "mat_firmother")
                record.setValue(objMattress.mattressReport, forKey: "mat_description")
                record.setValue(objMattress.lawTagsAttachedToMattress, forKey: "mat_law_tag")
                record.setValue(objMattress.doesBoxMatchMattress, forKey: "mat_match_box")
                record.setValue(objMattress.foundationDOB, forKey: "mat_mfg")
                record.setValue(objMattress.productName, forKey: "mat_productname")
                record.setValue(objMattress.size, forKey: "mat_size")
                record.setValue(objMattress.mattressId, forKey: "matter_id")
                record.setValue(objMattress.orderId, forKey: "order_id")
                record.setValue(objMattress.other, forKey: "other")
                record.setValue(objMattress.pillowTop, forKey: "pillow_top")
                record.setValue(objMattress.productType, forKey: "prod_type")
                record.setValue(objMattress.recommendedAction, forKey: "recommended")
                record.setValue(objMattress.singleSided, forKey: "single_sided")
                record.setValue(NSNumber.init(value: status), forKey: "isModify")
                record.setValue(modifyDate, forKey: "modified_date")
                
                self.updateMattressPhotosInCoreData(fromMattressObject: objMattress)
                self.updateMattressVideosInCoreData(fromMattressObject: objMattress)
                
                do
                {
                    try record.managedObjectContext?.save()
                }catch{
                    ////print("Failed to save city object :: At Index = \(index)")
                }
                
            }
            
        } catch {
            ////print(error)
        }
        
    }
    
    func updateMattressAfterSyncing(withMattressId mattressId:String, withIsModifyStatus status:Bool, withModifyDate modifyDate:Date) -> Void
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Mettress")
        fetchRequest.predicate = NSPredicate(format: "matter_id = %@ ", mattressId)
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            
            for record in records
            {
                
                record.setValue(NSNumber.init(value: status), forKey: "isModify")
                record.setValue(modifyDate, forKey: "modified_date")
                
                do
                {
                    try record.managedObjectContext?.save()
                }catch{
                    ////print("Failed to save city object :: At Index = \(index)")
                }
                
            }
            
        } catch {
            ////print(error)
        }
        
    }
    
    func updateOrderDetails(withOrderObject objOrder:CRMJob, withIsModifyStatus status:Bool, withModifyDate modifyDate:Date) -> Void
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderDetailTable")
        fetchRequest.predicate = NSPredicate(format: "o_id = %@ ", objOrder.o_id)
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            
            for record in records
            {
                record.setValue(objOrder.additionalInfo, forKey: "additional_info")
                record.setValue(objOrder.addressLine1, forKey: "address1")
                record.setValue(objOrder.addressLine2, forKey: "address2")
                record.setValue(objOrder.allottedDuration, forKey: "allotted_hours")
                record.setValue(objOrder.appointmentDate, forKey: "apntmnt_date")
                record.setValue(objOrder.appointmentDirection, forKey: "apntmnt_direction")
                record.setValue(objOrder.appointmentTime, forKey: "apntmnt_time")
                record.setValue(objOrder.city, forKey: "city")
                record.setValue(objOrder.clientOrderNo, forKey: "client_order_no")
                record.setValue(objOrder.email, forKey: "email")
                record.setValue(objOrder.firstName, forKey: "first_name")
                record.setValue(objOrder.homePhone, forKey: "home_phone")
                record.setValue(objOrder.isClose, forKey: "is_close")
                record.setValue(objOrder.work_phone, forKey: "work_phone")
                record.setValue(objOrder.mergeCompanyId, forKey: "merge_company_id")
                record.setValue(objOrder.signatureStatus, forKey: "signature_status")
                record.setValue(objOrder.refuseSignReason, forKey: "refuse_sign_reason")
                record.setValue(objOrder.isSchedule, forKey: "is_schedule")
                
                if objOrder.isAcknoledge == true
                {
                    record.setValue("1", forKey: "is_ack")
                }
                else
                {
                    record.setValue("0", forKey: "is_ack")
                }
                record.setValue(objOrder.isSubClose, forKey: "is_sub_close")
                record.setValue(objOrder.lastName, forKey: "last_name")
                record.setValue("\(objOrder.latitude)", forKey: "lat")
                record.setValue("\(objOrder.longitude)", forKey: "lng")
                record.setValue(objOrder.mobile, forKey: "mobile")
                record.setValue(objOrder.o_id, forKey: "o_id")
                record.setValue(objOrder.openDate, forKey: "open_date")
                record.setValue(objOrder.orderId, forKey: "order_id")
                record.setValue(objOrder.orderStatus, forKey: "order_status")
                record.setValue(objOrder.serviceInstruction, forKey: "service_instrcn")
                record.setValue(objOrder.serviceName, forKey: "service_name")
                record.setValue("\(objOrder.serviceStatus.id)", forKey: "service_status")
                record.setValue(objOrder.state, forKey: "state")
                record.setValue(objOrder.statusName, forKey: "status_name")
                record.setValue(objOrder.zipCode, forKey: "zipcode")
                record.setValue(objOrder.cityId, forKey: "city_id")
                record.setValue(objOrder.companyId, forKey: "company_id")
                record.setValue(objOrder.stateId, forKey: "state_id")
                record.setValue(objOrder.isMergeSubClose, forKey: "isMergeSubClose")
                record.setValue(objOrder.mergeTechId, forKey: "mergeTechId")
                record.setValue(objOrder.rescheduleReason, forKey: "reschedule_reson")
                record.setValue(objOrder.imageHeight, forKey: "heigth")
                record.setValue(objOrder.imageWidth, forKey: "width")
                

                //Urvish
                record.setValue(objOrder.techFeeLabor, forKey: "tech_fee_labor")
                record.setValue(objOrder.techFeeMileage, forKey: "tech_fee_mileage")
                record.setValue(objOrder.techTotalFee, forKey: "tech_total_fee")
                record.setValue(objOrder.techFeeParts, forKey: "tech_fee_parts")
                
                record.setValue(objOrder.mergeTechFeeLabor, forKey: "merge_tech_fee_labor")
                record.setValue(objOrder.mergeTechFeeMileage, forKey: "merge_tech_fee_mileage")
                record.setValue(objOrder.mergeTechFeeParts, forKey: "merge_tech_fee_parts")
                record.setValue(objOrder.mergeTechTotalFee, forKey: "merge_tech_total_fee")
                
                record.setValue(NSNumber.init(value: status), forKey: "isModify")
                record.setValue(modifyDate, forKey: "modify_date")
                
                
                for photo in objOrder.photos
                {
                    self.deletePhotoInCoreData(fromPId: "\(photo.imageId)")
                }
                for video in objOrder.videos
                {
                    self.deleteVideoInCoreData(fromVId:"\(video.videoId)")
                }
                for task in objOrder.orderTasks
                {
                    self.deleteTaskInCoreData(fromOId: task.itemId)
                }
                for mattress in objOrder.orderMattress
                {
                    self.deleteMattressInCoreData(fromOId: mattress.mattressId)
                }
                
                
                self.insertPhotoTable(withPhotoDetails:  objOrder.photos)
                self.insertVideoTable(withVideoDetails: objOrder.videos)
                self.insertTaskDataInCoreData(withArray: objOrder.orderTasks)
                self.insertMattressDataInCoreData(withArray: objOrder.orderMattress)
                
                do
                {
                    try record.managedObjectContext?.save()
                }catch{
                    ////print("Failed to save city object :: At Index = \(index)")
                }
                
            }
            
        } catch {
            ////print(error)
        }
        
    }
    //(withInvoiceList: objInvoice, withIsModifyStatus: false, withModifyDate: Date().timeStamp)
    func updateInvoiceList(withInvoiceList objInvoice:CRMInvoices, withIsModifyStatus status:Bool, withModifyDate modifyDate:Date) -> Void
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Invoice")
        fetchRequest.predicate = NSPredicate(format: "id = %@", objInvoice.strId)
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            
            for record in records
            {
                record.setValue(objInvoice.strId, forKey: "id")
                record.setValue(objInvoice.strInvoiceType, forKey: "type")
                record.setValue(objInvoice.strStatus, forKey: "status")
                record.setValue(objInvoice.strInvoiceDate, forKey: "date")
                record.setValue(objInvoice.strDifferenceAmt, forKey: "diffrence")
                record.setValue(objInvoice.strDescription, forKey: "desc")
                record.setValue(objInvoice.strApplied, forKey: "applied")
                //                record.setValue(NSNumber.init(value: status), forKey: "isModify")
                //                record.setValue(modifyDate, forKey: "modifyDate")
                
                do{
                    try record.managedObjectContext?.save()
                }catch{
                    ////print("Failed to save city object :: At Index = \(index)")
                }
                
            }
            
        } catch {
            ////print(error)
        }
        
    }
    
    func updateSeeLogsInCoreData(withSeeLogObject objSeeLog:CRMLogs) -> Void
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SeeLog")
        fetchRequest.predicate = NSPredicate(format: "id = %@", objSeeLog.id)
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            
            for record in records
            {
                record.setValue(objSeeLog.emailStatus, forKey: "email_status")
                record.setValue(objSeeLog.groupId, forKey: "group_id")
                record.setValue(objSeeLog.logId, forKey: "log_id")
                record.setValue(objSeeLog.memoCateId, forKey: "memo_cate_id")
                record.setValue(objSeeLog.memoStatus, forKey: "memo_status")
                record.setValue(objSeeLog.memoMsg, forKey: "memo_txt")
                record.setValue(objSeeLog.usersId, forKey: "users_id")
                record.setValue(objSeeLog.companyId, forKey: "company_id")
                record.setValue(objSeeLog.memoTxt, forKey: "id")
                record.setValue(objSeeLog.id, forKey: "memo_msg")
                record.setValue(objSeeLog.orderId, forKey: "order_id")
                record.setValue(objSeeLog.userId, forKey: "user_id")
                let strCreatedDate:String = objSeeLog.createdDate.convertDateInUTCDateString(withDateFormat: Constant.DateFormat.FullDateTimeTimezone, withConvertedDateFormat: Constant.DateFormat.FullDateWithTime)
                record.setValue(strCreatedDate, forKey: "created")
                let strModifiedDate:String = objSeeLog.modifiedData.convertDateInUTCDateString(withDateFormat: Constant.DateFormat.FullDateTimeTimezone, withConvertedDateFormat: Constant.DateFormat.FullDateWithTime)
                record.setValue(strModifiedDate, forKey: "modified")
                
                do{
                    try record.managedObjectContext?.save()
                }catch{
                    ////print("Failed to save city object :: At Index = \(index)")
                }
                
            }
            
        } catch {
            ////print(error)
        }
        
    }
    func updateInvoiceDetail(withInvoiceList objInvoice:CRMInvoiceOrder ) -> Void
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "InvoiceDetail")
        fetchRequest.predicate = NSPredicate(format: "id = %@", objInvoice.strId)
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            
            for record in records
            {
                record.setValue(objInvoice.strId, forKey: "id")
                record.setValue(objInvoice.strOId, forKey: "oid")
                record.setValue(objInvoice.strStatus, forKey: "statusname")
                record.setValue(objInvoice.strFirstName, forKey: "firstname")
                record.setValue(objInvoice.strLastName, forKey: "lastname")
                record.setValue(objInvoice.strApntmntDate, forKey: "apointmentdate")
                record.setValue(objInvoice.strTechFeeLabor, forKey: "techlabor")
                record.setValue(objInvoice.strTechFeeParts, forKey: "techparts")
                record.setValue(objInvoice.strTechFeeMileage, forKey: "techmileage")
                record.setValue(objInvoice.strTechTotalFee, forKey: "techtotalfee")
                
                do{
                    try record.managedObjectContext?.save()
                }catch{
                    ////print("Failed to save city object :: At Index = \(index)")
                }
                
            }
            
        } catch {
            ////print(error)
        }
    }
    
    func updatePhotoInCoreData(fromLocalLocation localLocation:String, andUploadStatus status:CRMUploadStatus, withPhotoObject objPhoto:CRMImage) -> [CRMFileUpload]
    {
        let syncingOrderQueue = DispatchQueue(label: "com.crm.technician.updateOrderPhoto", qos: .userInteractive)
        var aryFileUpload:[CRMFileUpload] = []
        
        
        syncingOrderQueue.sync {
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
            if let date:Date = objPhoto.createdDate
            {
                fetchRequest.predicate = NSPredicate(format: "localFileUrl = %@ AND created_date = %@ ", localLocation, date as CVarArg )
                
            }
            else
            {
                fetchRequest.predicate = NSPredicate(format: "localFileUrl = %@  ", localLocation)
            }
            
            
            do {
                let records = try managedObjectContext.fetch(fetchRequest) as! [Photo]
                for record in records
                {
                    record.modified_date = Date() as? NSDate
                    if objPhoto.imageId != 0
                    {
                        record.p_id = "\(objPhoto.imageId)"
                        record.localFileUrl = ""
                        record.file_key = ""
                        record.mine_type = ""
                    }
                    if objPhoto.imageName.characters.count > 0
                    {
                        record.photo_name = objPhoto.imageName
                        
                        
                    }
                    record.upload_status = status.rawValue
                    record.company_id = objPhoto.companyId;
                    
                    do{
                        
                        try record.managedObjectContext?.save()
                        print("photo update :: \(objPhoto.imageId)")
                        //return self.getRemainingPhotosForUploading()
                    }
                    catch
                    {
                        ////print("Error:: Photo is not updated")
                    }
                    
                }
            }
            catch
            {
                ////print(error)
                
            }
            
            
            
            
            let date:Date = Date()
            //print(date)
            
            let fetchPhotoRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
            //fetchRequest.predicate = NSPredicate(format: "upload_status = %@ OR upload_status = %@ ",CRMUploadStatus.pending.rawValue,CRMUploadStatus.failed.rawValue)
            fetchPhotoRequest.predicate = NSPredicate(format: " upload_status = %@ OR ( upload_status = %@  AND modified_date <= %@ ) ",CRMUploadStatus.pending.rawValue,CRMUploadStatus.failed.rawValue,date as CVarArg)
            
            //fetchRequest.predicate = NSPredicate(format: "upload_status = %@ ",CRMUploadStatus.pending.rawValue)
            do {
                
                if let photoFetch = try self.managedObjectContext.fetch(fetchPhotoRequest) as? [Photo]
                {
                    print("fetch count :: \(photoFetch.count)")
                    for  image in photoFetch
                    {
                        let objImage:CRMImage = CRMImage.init(withCoreDataObject: image)
                        
                        let fileUploader:CRMFileUpload = CRMFileUpload.init(withImageObject: objImage, withCompanyId: objImage.companyId)
                        aryFileUpload.append(fileUploader)
                        
                    }
                    
                    //return aryFileUpload
                }
            }
            catch
            {
                //print("Error in photo table")
            }
            let fetchVideoRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Video")
            fetchVideoRequest.predicate = NSPredicate(format: "upload_status = %@ OR ( upload_status = %@ AND modified_date <= %@ ) ",CRMUploadStatus.pending.rawValue,CRMUploadStatus.failed.rawValue, date as CVarArg)
            //fetchVideoRequest.predicate = NSPredicate(format: "upload_status = %@ ",CRMUploadStatus.pending.rawValue)
            do {
                
                if let videoFetch = try self.managedObjectContext.fetch(fetchVideoRequest) as? [Video]
                {
                    
                    for  video in videoFetch
                    {
                        let objVideo:CRMVideo = CRMVideo.init(withCoreDataObject: video)
                        let fileUploader:CRMFileUpload = CRMFileUpload.init(withVideoObject: objVideo, withCompanyId: objVideo.company_id)
                        aryFileUpload.append(fileUploader)
                        
                    }
                    //return aryFileUpload
                }
                
            }
            catch
            {
                //print("Error in Video");
            }
        }
        
        return aryFileUpload
        //return self.getRemainingPhotosForUploading()
        
    }
    
    func updatePhotoInCoreData(fromPId pId:String, withIsDeletedStatus status:Bool) -> Void
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "p_id = %@", pId)
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            for record in records
            {
                record.setValue(NSNumber.init(value: status), forKey: "isDelete")
                
                do{
                    
                    try record.managedObjectContext?.save()
                }
                catch
                {
                    ////print("Error:: Photo is not updated")
                }
                
            }
        }
        catch {
            ////print(error)
        }
        
    }
    func updatePhotoInCoreDataWhenOfflineDeletePhoto(fromImageObject objImage:CRMImage, withIsDeletedStatus status:Bool) -> Void
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        if objImage.imageId != 0
        {
            fetchRequest.predicate = NSPredicate(format: "p_id = %d ", objImage.imageId)
            
        }
        else
        {
            
            if objImage.createdDate != nil
            {
                //let strDate:String = ((objImage.createdDate?.convertDateInString(withDateFormat: Constant.DateFormat.FullDateTimeTimezone, withConvertedDateFormat: Constant.DateFormat.FullDateTimeTimezone)))!
                let date:Date = objImage.createdDate!
                
                fetchRequest.predicate = NSPredicate(format: "created_date == %@ AND localFileUrl = %@ ", date as CVarArg ,objImage.imageLocalLocation)
            }
        }
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            for record in records
            {
                record.setValue(NSNumber.init(value: status), forKey: "isDelete")
                record.setValue(CRMUploadStatus.pending.rawValue, forKey: "upload_status")
                
                do{
                    
                    try record.managedObjectContext?.save()
                }
                catch
                {
                    ////print("Error:: Photo is not updated")
                }
                
            }
        }
        catch {
            ////print(error)
        }
        
    }
    
    func updateVideoInCoreDataWhenOfflineDeleteVideo(fromImageObject objVideo:CRMVideo, withIsDeletedStatus status:Bool) -> Void
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Video")
        
        if objVideo.videoId != 0
        {
            fetchRequest.predicate = NSPredicate(format: "v_id = %d ", objVideo.videoId)
            
        }
        else
        {
            
            if objVideo.createdDate != nil
            {
                
                let date:Date = objVideo.createdDate!
                
                fetchRequest.predicate = NSPredicate(format: "created_date == %@ AND localFileUrl = %@ ", date as CVarArg ,objVideo.localPath)
            }
            
        }
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            for record in records
            {
                record.setValue(NSNumber.init(value: status), forKey: "isDelete")
                record.setValue(CRMUploadStatus.pending.rawValue, forKey: "upload_status")
                
                do{
                    
                    try record.managedObjectContext?.save()
                }
                catch
                {
                    ////print("Error:: Video is not updated")
                }
                
            }
        }
        catch {
            ////print(error)
        }
        
    }
    
    
    func updateVideoInCoreData(fromLocalLocation localLocation:String, andUploadStatus status:CRMUploadStatus, withPhotoObject objVideo:CRMVideo) -> [CRMFileUpload]
    {
        let syncingOrderQueue = DispatchQueue(label: "com.crm.technician.updateOrderVideo", qos: .userInteractive)
        var aryFileUpload:[CRMFileUpload] = []
        
        syncingOrderQueue.sync {
            
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Video")
            if let date:Date = objVideo.createdDate
            {
                fetchRequest.predicate = NSPredicate(format: "localFileUrl = %@ AND created_date == %@ ", localLocation,date as CVarArg)
            }
            else
            {
                fetchRequest.predicate = NSPredicate(format: "localFileUrl = %@", localLocation)
            }
            
            
            
            do {
                let records = try managedObjectContext.fetch(fetchRequest) as! [Video]
                for record in records
                {
                    record.modified_date = Date() as? NSDate
                    if objVideo.videoId != 0
                    {
                        record.v_id = "\(objVideo.videoId)"
                        record.localFileUrl = ""
                        record.file_key = ""
                        record.mine_type = ""
                    }
                    if objVideo.fileName.characters.count > 0
                    {
                        record.video_name = objVideo.fileName
                    }
                    record.video_image = objVideo.videoImage
                    record.upload_status = status.rawValue
                    record.company_id = objVideo.company_id;
                    
                    do{
                        
                        try record.managedObjectContext?.save()
                        //return self.getRemainingPhotosForUploading()
                    }
                    catch
                    {
                        ////print("Error:: Photo is not updated")
                    }
                    
                }
            }
            catch {
                ////print(error)
                
            }
            
            
            
            
            let date:Date = Date()
            //print(date)
            
            let fetchRequestPhoto = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
            //fetchRequest.predicate = NSPredicate(format: "upload_status = %@ OR upload_status = %@ ",CRMUploadStatus.pending.rawValue,CRMUploadStatus.failed.rawValue)
            fetchRequestPhoto.predicate = NSPredicate(format: " upload_status = %@ OR ( upload_status = %@  AND modified_date <= %@ ) ",CRMUploadStatus.pending.rawValue,CRMUploadStatus.failed.rawValue,date as CVarArg)
            
            //fetchRequest.predicate = NSPredicate(format: "upload_status = %@ ",CRMUploadStatus.pending.rawValue)
            do {
                
                if let photoFetch = try self.managedObjectContext.fetch(fetchRequestPhoto) as? [Photo]
                {
                    
                    for  image in photoFetch
                    {
                        let objImage:CRMImage = CRMImage.init(withCoreDataObject: image)
                        
                        let fileUploader:CRMFileUpload = CRMFileUpload.init(withImageObject: objImage, withCompanyId: objImage.companyId)
                        aryFileUpload.append(fileUploader)
                        
                    }
                    //return aryFileUpload
                }
            }
            catch
            {
                //print("Error in photo table")
            }
            let fetchVideoRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Video")
            fetchVideoRequest.predicate = NSPredicate(format: "upload_status = %@ OR ( upload_status = %@ AND modified_date <= %@ ) ",CRMUploadStatus.pending.rawValue,CRMUploadStatus.failed.rawValue, date as CVarArg)
            //fetchVideoRequest.predicate = NSPredicate(format: "upload_status = %@ ",CRMUploadStatus.pending.rawValue)
            do {
                
                if let videoFetch = try self.managedObjectContext.fetch(fetchVideoRequest) as? [Video]
                {
                    
                    for  video in videoFetch
                    {
                        let objVideo:CRMVideo = CRMVideo.init(withCoreDataObject: video)
                        let fileUploader:CRMFileUpload = CRMFileUpload.init(withVideoObject: objVideo, withCompanyId: objVideo.company_id)
                        aryFileUpload.append(fileUploader)
                        
                    }
                    //return aryFileUpload
                }
                
            }
            catch
            {
                //print("Error in Video");
            }
        }
        
        
        return aryFileUpload
        
        //return self.getRemainingPhotosForUploading()
        
    }
    func updateTaskPhotosInCoreData(fromTaskObject objTask:CRMTask) -> Void
    {
        
        self.deletePhotoInCoreData(fromOId: objTask.orderId, withItemId: objTask.itemId, withType: "item")
        
        self.insertPhotoTable(withPhotoDetails: objTask.aryImages)
        
    }
    func updateTaskVideosInCoreData(fromTaskObject objTask:CRMTask) -> Void
    {
        
        self.deleteVideoInCoreData(fromOId: objTask.orderId, withItemId: objTask.itemId, withType: "item")
        
        self.insertVideoTable(withVideoDetails: objTask.aryVideos)
        
    }
    func updateMattressPhotosInCoreData(fromMattressObject objTask:CRMMattress) -> Void
    {
        
        self.deletePhotoInCoreData(fromOId: objTask.orderId, withItemId: objTask.mattressId, withType: "mattress")
        
        self.insertPhotoTable(withPhotoDetails: objTask.aryImages)
        
    }
    func updateMattressVideosInCoreData(fromMattressObject objTask:CRMMattress) -> Void
    {
        
        self.deleteVideoInCoreData(fromOId: objTask.orderId, withItemId: objTask.mattressId, withType: "mattress")
        
        self.insertVideoTable(withVideoDetails: objTask.aryVideos)
        
    }
    
    
    //MARK:- Delete
    func deletePhotoInCoreData(fromPId pId:String) -> Void
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "p_id = %@", pId)
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            for record in records
            {
                self.managedObjectContext.delete(record)
            }
        }
        catch {
            ////print(error)
        }
    }
    
    
    
    func deletePhotoInCoreData(fromOId oId:String,withItemId itemId:String, withType type:String) -> Void
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "order_id = %@ AND order_item_id = %@ AND type= %@ AND upload_status = %@", oId,itemId,type,CRMUploadStatus.uploaded.rawValue)
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            for record in records
            {
                self.managedObjectContext.delete(record)
            }
        }
        catch {
            ////print(error)
        }
    }
    func deletePhotoInCoreData(fromOId oId:String,withType type:String) -> Void
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "order_id = %@ AND type= %@ ", oId,type)
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            for record in records
            {
                self.managedObjectContext.delete(record)
            }
        }
        catch {
            ////print(error)
        }
    }
    func deletePhotoInCoreData(fromPhotoObject objImage:CRMImage) -> Void
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        if objImage.imageId != 0
        {
            fetchRequest.predicate = NSPredicate(format: "p_id = %d ", objImage.imageId)
            
        }
        else
        {
            if objImage.createdDate != nil
            {
                //let strDate:String = ((objImage.createdDate?.convertDateInString(withDateFormat: Constant.DateFormat.FullDateTimeTimezone, withConvertedDateFormat: Constant.DateFormat.FullDateTimeTimezone)))!
                let date:Date = objImage.createdDate!
                
                fetchRequest.predicate = NSPredicate(format: "created_date == %@ AND localFileUrl = %@ ", date as CVarArg ,objImage.imageLocalLocation)
            }
        }
        
        
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            for record in records
            {
                self.managedObjectContext.delete(record)
            }
        }
        catch {
            ////print(error)
        }
    }
    
    func deleteVideoInCoreData(fromVId vId:String) -> Void
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Video")
        fetchRequest.predicate = NSPredicate(format: "v_id = %@", vId)
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            
            for record in records {
                self.managedObjectContext.delete(record)
            }
        }
        catch {
            ////print(error)
        }
        
    }
    func deleteVideoInCoreData(fromVideoObject  objVideo:CRMVideo) -> Void
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Video")
        if objVideo.videoId != 0
        {
            fetchRequest.predicate = NSPredicate(format: "v_id = %@ ", objVideo.videoId)
            
        }
        else
        {
            
            if objVideo.createdDate != nil
            {
                
                let date:Date = objVideo.createdDate!
                
                fetchRequest.predicate = NSPredicate(format: "created_date == %@ AND localFileUrl = %@ ", date as CVarArg ,objVideo.localPath)
            }
            
        }
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            
            for record in records {
                self.managedObjectContext.delete(record)
            }
        }
        catch {
            ////print(error)
        }
        
    }
    
    func deleteVideoInCoreData(fromOId oId:String,withItemId itemId:String, withType type:String) -> Void
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Video")
        fetchRequest.predicate = NSPredicate(format: "order_id = %@ AND order_item_id = %@ AND type = %@ AND upload_status = %@", oId,itemId,type,CRMUploadStatus.uploaded.rawValue)
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            for record in records
            {
                self.managedObjectContext.delete(record)
            }
        }
        catch {
            ////print(error)
        }
    }
    
    func deleteTaskInCoreData(fromOId orderId:String) -> Void
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "item_id = %@", orderId)
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            
            for record in records {
                self.managedObjectContext.delete(record)
            }
        }
        catch {
            ////print(error)
        }
        
    }
    func deleteMattressInCoreData(fromOId orderId:String) -> Void
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Mettress")
        fetchRequest.predicate = NSPredicate(format: "matter_id = %@", orderId)
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            
            for record in records {
                self.managedObjectContext.delete(record)
            }
        }
        catch {
            ////print(error)
        }
        
    }
    
    func deleteItemPartsInCoreData(fromPartsId partId:String) -> Void
    {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PartsDetails")
        fetchRequest.predicate = NSPredicate(format: "part_id = %@", partId)
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            
            for record in records {
                self.managedObjectContext.delete(record)
            }
        }
        catch {
            ////print(error)
        }
        
    }
    func deleteItemPartsInCoreData(fromPartDetails partDetails:[String:Any]) -> Void
    {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PartsDetails")
        
        if let strCreatedDate:String = partDetails["created"] as? String
        {
            let date:Date = strCreatedDate.getDate(withDateFormate: Constant.DateFormat.FullDateWithTime)!
            let strPartsDetails:String = partDetails["part_detail"] as! String
            let strItemId:String = partDetails["item_id"] as! String
            let strOrderId:String = partDetails["order_id"] as! String
            fetchRequest.predicate = NSPredicate(format: "part_detail = %@ AND item_id = %@ AND                order_id = %@ ", strPartsDetails ,strItemId,strOrderId)
            
            //fetchRequest.predicate = NSPredicate(format: "part_detail = %@ AND createdDate = %@ ", strPartsDetails ,date as CVarArg)
        }
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            
            for record in records
            {
                self.managedObjectContext.delete(record)
            }
        }
        catch
        {
            ////print(error)
        }
        
    }
    
    func deleteItemPartsInCoreData(fromPartObject objPart:CRMPartDetails) -> Void
    {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PartsDetails")
        if objPart.part_id.characters.count > 0
        {
            fetchRequest.predicate = NSPredicate(format: "part_id = %@", objPart.part_id)
            
        }
        else
        {
            if objPart.createdDate != nil
            {
                //let strDate:String = ((objImage.createdDate?.convertDateInString(withDateFormat: Constant.DateFormat.FullDateTimeTimezone, withConvertedDateFormat: Constant.DateFormat.FullDateTimeTimezone)))!
                let date:Date = objPart.createdDate!
                
                fetchRequest.predicate = NSPredicate(format: "createdDate == %@ AND part_detail = %@ ", date as CVarArg,objPart.part_detail )
            }
        }
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            
            for record in records {
                self.managedObjectContext.delete(record)
            }
        }
        catch {
            ////print(error)
        }
        
    }
    
    func deleteOrderScheduleInCoreData(fromOrderId orderId:String) -> Void
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderScheduleTable")
        fetchRequest.predicate = NSPredicate(format: "o_id = %@", orderId)
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            
            for record in records
            {
                self.managedObjectContext.delete(record)
            }
        }
        catch {
            ////print(error)
        }
        
    }
    
    func deleteOrderStatusInCoreData(fromOrderId orderId:String) -> Void
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OrderStatusTable")
        fetchRequest.predicate = NSPredicate(format: "o_id = %@", orderId)
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            
            for record in records {
                self.managedObjectContext.delete(record)
            }
        }
        catch {
            ////print(error)
        }
        
    }
    //MARK:- Syncing Method
    func getUpdatedOrderStatusListForSync() -> [[String:Any]]
    {
        let orderStatusFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "OrderStatusTable")
        orderStatusFetchRequest.predicate = NSPredicate(format: "isModify = 1")
        let sortDescriptor = NSSortDescriptor(key: "modifyDate", ascending: false)
        orderStatusFetchRequest.sortDescriptors = [sortDescriptor]
        
        orderStatusFetchRequest.entity = NSEntityDescription.entity(forEntityName: "OrderStatusTable", in: self.managedObjectContext)
        do {
            if let orderStatusFetch = try self.managedObjectContext.fetch(orderStatusFetchRequest) as? [OrderStatusTable]
            {
                var aryOrderStatus:[[String:Any]] = []
                for orderStatus in orderStatusFetch
                {
                    var dictTemp:[String : Any] = [:]
                    dictTemp["user_id"] = orderStatus.user_id
                    dictTemp["order_id"] = orderStatus.o_id
                    dictTemp["status_id"] = orderStatus.service_status
                    if let value:Date = orderStatus.modifyDate as? Date
                    {
                        dictTemp["modified"] = value.convertDateInUTCDateString(withDateFormat: "yyyy-MM-dd HH:mm:ss z", withConvertedDateFormat: "yyyy-MM-dd HH:mm:ss")
                    }
                    aryOrderStatus.append(dictTemp)
                    
                }
                return aryOrderStatus
            }else{
                return []
            }
        }catch{
            return []
        }
        
    }
    func getUpdatedOrderScheduleListForSync() -> [[String:Any]]
    {
        let orderScheduleFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "OrderScheduleTable")
        orderScheduleFetchRequest.predicate = NSPredicate(format: "isModify = 1")
        
        let sortDescriptor = NSSortDescriptor(key: "modifyDate", ascending: false)
        orderScheduleFetchRequest.sortDescriptors = [sortDescriptor]
        
        orderScheduleFetchRequest.entity = NSEntityDescription.entity(forEntityName: "OrderScheduleTable", in: self.managedObjectContext)
        do {
            if let orderScheduleFetch = try self.managedObjectContext.fetch(orderScheduleFetchRequest) as? [OrderScheduleTable]
            {
                var aryOrderSchedule:[[String:Any]] = []
                for orderSchedule in orderScheduleFetch
                {
                    var dictTemp:[String : Any] = [:]
                    dictTemp["user_id"] = orderSchedule.user_id
                    dictTemp["order_id"] = orderSchedule.o_id
                    dictTemp["apntmnt_date"] = orderSchedule.apntmnt_date
                    dictTemp["apntmnt_time"] = orderSchedule.apntmnt_time
                    if (orderSchedule.reschedule_reson?.characters.count)! > 0
                    {
                        dictTemp["reschedule_reson"] = orderSchedule.reschedule_reson
                    }
                    if (orderSchedule.seven_days_reason?.characters.count)! > 0
                    {
                        dictTemp["seven_days_reason"] = orderSchedule.seven_days_reason
                    }
                    
                    if let value:Date = orderSchedule.modifyDate as? Date
                    {
                        dictTemp["modified"] = value.convertDateInUTCDateString(withDateFormat: "yyyy-MM-dd HH:mm:ss z", withConvertedDateFormat: "yyyy-MM-dd HH:mm:ss")
                    }
                    aryOrderSchedule.append(dictTemp)
                    
                }
                return aryOrderSchedule
            }else{
                return []
            }
        }catch{
            return []
        }
    }
    func getPhotoListForSync() -> [[String:Any]]
    {
        let photoFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Photo")
        photoFetchRequest.entity = NSEntityDescription.entity(forEntityName: "Photo", in: self.managedObjectContext)
        photoFetchRequest.predicate = NSPredicate.init(format: "isDelete = 1 ")
        let sortDescriptor = NSSortDescriptor(key: "modified_date", ascending: false)
        photoFetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            if let photoFetch = try self.managedObjectContext.fetch(photoFetchRequest) as? [Photo]
            {
                var aryPhoto:[[String:Any]] = []
                for photo in photoFetch
                {
                    var dictTemp:[String : Any] = [:]
                    dictTemp["p_id"] = photo.p_id
                    dictTemp["photo_name"] = photo.photo_name
                    if let value:Date = photo.modified_date as? Date
                    {
                        dictTemp["modified"] = value.convertDateInUTCDateString(withDateFormat: "yyyy-MM-dd HH:mm:ss z", withConvertedDateFormat: "yyyy-MM-dd HH:mm:ss")
                    }
                    aryPhoto.append(dictTemp)
                }
                return aryPhoto
            }else{
                return []
            }
        }catch{
            return []
        }
    }
    func getVideoListForSync() -> [[String:Any]]
    {
        let videoFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Video")
        videoFetchRequest.entity = NSEntityDescription.entity(forEntityName: "Video", in: self.managedObjectContext)
        videoFetchRequest.predicate = NSPredicate.init(format: "isDelete = 1 ")
        let sortDescriptor = NSSortDescriptor(key: "modified_date", ascending: false)
        videoFetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            if let videoFetch = try self.managedObjectContext.fetch(videoFetchRequest) as? [Video]
            {
                var aryVideo:[[String:Any]] = []
                for video in videoFetch
                {
                    var dictTemp:[String : Any] = [:]
                    dictTemp["p_id"] = video.v_id
                    dictTemp["video_name"] = video.video_name
                    if let value:Date = video.modified_date as? Date
                    {
                        dictTemp["modified"] = value.convertDateInUTCDateString(withDateFormat: "yyyy-MM-dd HH:mm:ss z", withConvertedDateFormat: "yyyy-MM-dd HH:mm:ss")
                    }
                    aryVideo.append(dictTemp)
                }
                return aryVideo
            }else{
                return []
            }
        }catch{
            return []
        }
    }
    
    func getUpdatedTechnicianUserListForSync() -> [CRMSubTechnician]
    {
        let subTechnicianFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "SubTechnician")
        subTechnicianFetchRequest.predicate = NSPredicate(format: "isModify = 1")
        let sortDescriptor = NSSortDescriptor(key: "modifyDate", ascending: false)
        subTechnicianFetchRequest.sortDescriptors = [sortDescriptor]
        
        subTechnicianFetchRequest.entity = NSEntityDescription.entity(forEntityName: "SubTechnician", in: self.managedObjectContext)
        do {
            if let subTechnicianFetch = try self.managedObjectContext.fetch(subTechnicianFetchRequest) as? [SubTechnician]
            {
                var arySubTechnician:[CRMSubTechnician] = []
                for subTechnician in subTechnicianFetch{
                    ////print(subTechnician)
                    
                    arySubTechnician.append(CRMSubTechnician(WithCoreDataObject: subTechnician))
                    
                }
                return arySubTechnician
            }else{
                return []
            }
        }catch{
            return []
        }
        
    }
    func getUpdatedItemPartsListForSync() -> [[String:Any]]
    {
        
        let subTechnicianFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "PartsDetails")
        subTechnicianFetchRequest.predicate = NSPredicate(format: "part_id = %@ OR part_id = nil ","")
        
        let sortDescriptor = NSSortDescriptor(key: "modifiedDate", ascending: false)
        subTechnicianFetchRequest.sortDescriptors = [sortDescriptor]
        
        subTechnicianFetchRequest.entity = NSEntityDescription.entity(forEntityName: "PartsDetails", in: self.managedObjectContext)
        do {
            if let subTechnicianFetch = try self.managedObjectContext.fetch(subTechnicianFetchRequest) as? [PartsDetails]
            {
                var arySubTechnician:[[String:Any]] = []
                for subTechnician in subTechnicianFetch{
                    ////print(subTechnician)
                    
                    let objPart:CRMPartDetails = CRMPartDetails.init(withCoreData: subTechnician)
                    
                    var dictData:[String:Any] = ["item_id":objPart.item_id];
                    dictData["order_id"] = objPart.order_id
                    dictData["part_detail"] = objPart.part_detail
                    dictData["created"] = objPart.createdDate?.getDateInString(withFormat: Constant.DateFormat.FullDateWithTime)
                    arySubTechnician.append(dictData)
                }
                return arySubTechnician
            }else{
                return []
            }
        }catch{
            return []
        }
        
    }
    func getDeletedItemPartsListForSync() -> [[String:Any]]
    {
        
        let subTechnicianFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "PartsDetails")
        subTechnicianFetchRequest.predicate = NSPredicate(format: "isDeletedPart = 1 ")
        
        let sortDescriptor = NSSortDescriptor(key: "modifiedDate", ascending: false)
        subTechnicianFetchRequest.sortDescriptors = [sortDescriptor]
        
        subTechnicianFetchRequest.entity = NSEntityDescription.entity(forEntityName: "PartsDetails", in: self.managedObjectContext)
        do {
            if let subTechnicianFetch = try self.managedObjectContext.fetch(subTechnicianFetchRequest) as? [PartsDetails]
            {
                var arySubTechnician:[[String:Any]] = []
                for subTechnician in subTechnicianFetch{
                    ////print(subTechnician)
                    
                    let objPart:CRMPartDetails = CRMPartDetails.init(withCoreData: subTechnician)
                    
                    var dictData:[String:Any] = [:]
                    dictData["part_id"] = objPart.part_id
                    dictData["modified"] = Date().getDateInString(withFormat: "yyyy-MM-dd hh:mm:ss")
                    
                    arySubTechnician.append(dictData)
                }
                return arySubTechnician
            }else{
                return []
            }
        }catch{
            return []
        }
        
    }
    
    func getUpdatedTaskListForSync() -> [[String:Any]]
    {
        let taskFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Task")
        taskFetchRequest.predicate = NSPredicate(format: "isModify = 1")
        
        let sortDescriptor = NSSortDescriptor(key: "modified_date", ascending: false)
        taskFetchRequest.sortDescriptors = [sortDescriptor]
        
        taskFetchRequest.entity = NSEntityDescription.entity(forEntityName: "Task", in: self.managedObjectContext)
        do {
            if let taskFetch = try self.managedObjectContext.fetch(taskFetchRequest) as? [Task]
            {
                var aryTask:[[String:Any]] = []
                for task in taskFetch{
                    ////print(task)
                    
                    let objTask:CRMTask = CRMTask.init(withCoreDataObject: task)
                    var paramsForTask:[String:Any] = [:]
                    paramsForTask["item_id"] = objTask.itemId
                    paramsForTask["company_id"] = objTask.companyId
                    paramsForTask["order_id"] = objTask.orderId
                    paramsForTask["creator_id"] = objTask.creatorId
                    paramsForTask["title"] = objTask.title
                    paramsForTask["additional_info"] = objTask.additionalInfo
                    paramsForTask["vendor_id"] = objTask.vendor.user_id
                    paramsForTask["style"] = objTask.style
                    paramsForTask["ack"] = objTask.SN_ID_ACK
                    paramsForTask["retail_price"] = objTask.retailPrice
                    paramsForTask["mfg_date"] = objTask.MFG_Date
                    paramsForTask["service_type"] = "\(objTask.taskType.id)"
                    paramsForTask["model"] = objTask.model
                    paramsForTask["condition"] = "\(objTask.condition.id)"
                    paramsForTask["cause"] = "\(objTask.cause.id)"
                    paramsForTask["status"] = "\(objTask.status.id)"
                    paramsForTask["cause_reason"] = "\(objTask.subCause.id)"
                    paramsForTask["other_cause_reason"] = objTask.reasonOfCause
                    paramsForTask["estimate_only_price"] = objTask.estimatedOnlyPrice
                    paramsForTask["technician_comment"] = objTask.techComments
                    paramsForTask["revised_comments"] = objTask.revisedComments
                    paramsForTask["modified"] =  objTask.modified
                    //addTaskRequest.reasonOfCause = "\(self.objModel.taskData.subCause.id)"
                    
                    aryTask.append(paramsForTask)
                    
                }
                return aryTask
            }else{
                return []
            }
        }catch{
            return []
        }
        
    }
    
    func getUpdatedMattressListForSync() -> [[String:Any]]
    {
        let mattressFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Mettress")
        mattressFetchRequest.predicate = NSPredicate(format: "isModify = 1")
        
        let sortDescriptor = NSSortDescriptor(key: "modified_date", ascending: false)
        mattressFetchRequest.sortDescriptors = [sortDescriptor]
        
        mattressFetchRequest.entity = NSEntityDescription.entity(forEntityName: "Mettress", in: self.managedObjectContext)
        do {
            if let mattressFetch = try self.managedObjectContext.fetch(mattressFetchRequest) as? [Mettress]
            {
                var aryMattress:[[String:Any]] = []
                for mattress in mattressFetch{
                    ////print(task)
                    
                    let objMattress:CRMMattress = CRMMattress.init(withCoreDataObject: mattress)
                    /*
                     var paramsForMattress:[String:Any] = [:]
                     paramsForMattress["matter_id"] = objMattress.mattressId
                     paramsForMattress["company_id"] = objMattress.companyId
                     paramsForMattress["order_id"] = objMattress.orderId
                     paramsForMattress["creator_id"] = objMattress.creatorId
                     paramsForMattress["single_sided"] = objMattress.singleSided
                     paramsForMattress["pillow_top"] = objMattress.pillowTop
                     paramsForMattress["manufacturer"] = objMattress.manufacturer
                     paramsForMattress["mat_productname"] = objMattress.productName
                     paramsForMattress["mat_size"] = objMattress.size
                     paramsForMattress["firmness"] = objMattress.firmness
                     paramsForMattress["mat_firmother"] = objMattress.firmnessOther
                     paramsForMattress["prod_type"] = objMattress.productType
                     paramsForMattress["other"] = objMattress.other
                     paramsForMattress["label_name"] = objMattress.labelName
                     paramsForMattress["label_code"] = objMattress.labelCode
                     paramsForMattress["mat_mfg"] = objMattress.foundationDOB
                     paramsForMattress["mat_description"] = objMattress.mattressReport
                     paramsForMattress["mat_law_tag"] = objMattress.lawTagsAttachedToMattress
                     paramsForMattress["box"] = objMattress.box
                     paramsForMattress["mat_match_box"] = objMattress.doesBoxMatchMattress
                     paramsForMattress["mat_box_mfg"] = objMattress.mattressDOB
                     paramsForMattress["box_description"] = objMattress.boxReport
                     paramsForMattress["frame_type"] = objMattress.frameType
                     paramsForMattress["frame_slats"] = objMattress.frameWithSlate
                     paramsForMattress["frame_description"] = objMattress.frameReport
                     paramsForMattress["recommended"] = objMattress.recommendedAction
                     //paramsForMattress["delete_status"] = objMattress.
                     paramsForMattress["cause"] = "\(objMattress.cause.id)"
                     paramsForMattress["cause_reason"] = objMattress.reasonOfCause
                     paramsForMattress["modified"] =  objMattress.modifiedDate
                     */
                    var paramsForMattress:[String:Any] = ["description_title":objMattress.strDescription]
                    paramsForMattress["single_sided"] = objMattress.singleSided
                    paramsForMattress["pillow_top"] = objMattress.pillowTop
                    paramsForMattress["manufacturer"] = objMattress.manufacturer
                    paramsForMattress["mat_productname"] = objMattress.productName
                    paramsForMattress["mat_size"] = objMattress.size
                    paramsForMattress["prod_type"] = objMattress.productType
                    paramsForMattress["mat_description"] = objMattress.mattressReport
                    paramsForMattress["mat_firmother"] = objMattress.firmnessOther
                    paramsForMattress["label_name"] = objMattress.labelName
                    paramsForMattress["label_code"] = objMattress.labelCode
                    paramsForMattress["mat_mfg"] = objMattress.mattressDOB
                    paramsForMattress["mat_law_tag"] = objMattress.lawTagsAttachedToMattress
                    paramsForMattress["box"] = objMattress.box
                    var strFirmness:String = ""
                    for firmness in objMattress.aryFirmness
                    {
                        if firmness.selectedItem == true
                        {
                            if strFirmness.characters.count > 0
                            {
                                strFirmness = strFirmness.appending(",\(firmness.name)")
                            }
                            else
                            {
                                strFirmness = firmness.name
                            }
                        }
                    }
                    paramsForMattress["firmness"] = strFirmness
                    paramsForMattress["mat_match_box"] = objMattress.doesBoxMatchMattress
                    paramsForMattress["have_stains"] = objMattress.mattressHaveStains
                    paramsForMattress["any_damage"] = objMattress.mattressHaveDamage
                    paramsForMattress["mat_box_mfg"] = objMattress.foundationDOB
                    paramsForMattress["box_description"] = objMattress.boxReport
                    paramsForMattress["frame_type"] = objMattress.frameType
                    paramsForMattress["frame_slats"] = objMattress.frameWithSlate
                    paramsForMattress["recommended"] = objMattress.recommendedAction
                    paramsForMattress["cause"] = "\(objMattress.cause.id)"
                    paramsForMattress["cause_reason"] = "\(objMattress.subCause.id)"
                    paramsForMattress["other_cause_reason"] = objMattress.reasonOfCause
                    paramsForMattress["frame_description"] = objMattress.frameReport
                    paramsForMattress["other"] = objMattress.other
                    paramsForMattress["order_id"] = objMattress.orderId
                    paramsForMattress["creator_id"] = CRMUser.shared.userId
                    paramsForMattress["company_id"] = objMattress.companyId
                    paramsForMattress["modified"] =  objMattress.modifiedDate
                    paramsForMattress["matter_id"] = objMattress.mattressId
                    
                    aryMattress.append(paramsForMattress)
                    
                }
                return aryMattress
            }else{
                return []
            }
        }catch{
            return []
        }
        
    }
    func getUpdatedSignatureForSync() -> [[String:Any]]
    {
        
        let orderDetailsFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "OrderDetailTable")
        orderDetailsFetchRequest.predicate = NSPredicate(format: "isModify = 1")
        
        let sortDescriptor = NSSortDescriptor(key: "modify_date", ascending: false)
        orderDetailsFetchRequest.sortDescriptors = [sortDescriptor]
        
        orderDetailsFetchRequest.entity = NSEntityDescription.entity(forEntityName: "OrderDetailTable", in: self.managedObjectContext)
        do {
            if let orderDetailsFetch = try self.managedObjectContext.fetch(orderDetailsFetchRequest) as? [OrderDetailTable]
            {
                var aryOrders:[[String:Any]] = []
                for order in orderDetailsFetch
                {
                    ////print(task)
                    
                    let objJobs:CRMJob = CRMJob.init(WithCoreDataObject: order)
                    var paramsForTask:[String:Any] = [:]
                    paramsForTask["company_id"] = objJobs.companyId
                    paramsForTask["order_id"] = objJobs.o_id
                    paramsForTask["signature_status"] = objJobs.signatureStatus
                    paramsForTask["refuse_sign_reason"] = objJobs.refuseSignReason
                    if let value:Date = objJobs.modifiedDate
                    {
                        paramsForTask["modified"] = value.convertDateInUTCDateString(withDateFormat: "yyyy-MM-dd HH:mm:ss z", withConvertedDateFormat: "yyyy-MM-dd HH:mm:ss")
                    }
                    aryOrders.append(paramsForTask)
                    
                }
                return aryOrders
            }else{
                return []
            }
        }catch{
            return []
        }
        
    }
    
    //MARK:- PreLoad CoreData Content Helpers
    private func parseCityCSV() -> [(cityId:String, stateId:String, cityName: String, areaCode: String, status: String,created:String, modified:String)] {
        // Load the CSV file and parse it
        
        if let pathForCSV = Bundle.main.path(forResource: "service_hub_city", ofType: "csv"){
            let csvURL = URL.init(fileURLWithPath: pathForCSV)
            
            let delimiter = ";"
            var stations:[(cityId:String, stateId:String, cityName: String, areaCode: String, status: String,created:String, modified:String)] = []
            
            do{
                let data = try Data(contentsOf: csvURL)
                if let content =  String(data: data, encoding: String.Encoding.utf8){
                    //existing code
                    let lines:[String] = content.components(separatedBy: NSCharacterSet.newlines) as [String]
                    
                    for line in lines {
                        var values:[String] = []
                        if line != "" {
                            // For a line with double quotes
                            // we use NSScanner to perform the parsing
                            
                            if line.range(of: "\"") != nil {
                                var textToScan:String = line
                                var value:NSString?
                                var textScanner:Scanner = Scanner(string: textToScan)
                                while textScanner.string != "" {
                                    
                                    if (textScanner.string as NSString).substring(to: 1) == "\"" {
                                        textScanner.scanLocation += 1
                                        textScanner.scanUpTo("\"", into: &value)
                                        textScanner.scanLocation += 1
                                    } else {
                                        textScanner.scanUpTo(delimiter, into: &value)
                                    }
                                    
                                    // Store the value into the values array
                                    values.append(value as! String)
                                    
                                    // Retrieve the unscanned remainder of the string
                                    if textScanner.scanLocation < textScanner.string.characters.count {
                                        textToScan = (textScanner.string as NSString).substring(from: textScanner.scanLocation + 1)
                                    } else {
                                        textToScan = ""
                                    }
                                    textScanner = Scanner(string: textToScan)
                                }
                                
                                // For a line without double quotes, we can simply separate the string
                                // by using the delimiter (e.g. comma)
                            } else  {
                                values = line.components(separatedBy: delimiter)
                            }
                            //////print(values)
                            // Put the values into the tuple and add it to the items array
                            let city = (cityId: values[0], stateId: values[1], cityName:  values[2], areaCode:  values[3], status:  values[4],created: values[5], modified: values[6])
                            stations.append(city)
                        }
                    }
                }
            }catch{
            }
            return stations
        }else{
            return []
        }
    }
    //id,name,exercise_type,category,difficulty_level,equipment_type,muscle_targeted,description,benefits,wrokout_time,image,animation_url,video_url
    
    private func parseWorkoutCSV() -> [(id:String, name:String, exerciseType: String, difficultyLevel: String, equipmentType: String,muscleTargeted:String, description:String, benefits:String, wrokoutTime:String, image:String, animationUrl:String, videoUrl:String)]
    {
        // Load the CSV file and parse it
        
        if let pathForCSV = Bundle.main.path(forResource: "workout_CSV", ofType: "csv"){
            let csvURL = URL.init(fileURLWithPath: pathForCSV)
            
            let delimiter = ","
            var stations:[(id:String, name:String, exerciseType: String, difficultyLevel: String, equipmentType: String,muscleTargeted:String, description:String, benefits:String, wrokoutTime:String, image:String, animationUrl:String, videoUrl:String)] = []
            
            do{
                let data = try Data(contentsOf: csvURL)
                if let content =  String(data: data, encoding: String.Encoding.utf8){
                    //existing code
                    let lines:[String] = content.components(separatedBy: NSCharacterSet.newlines) as [String]
                    //print(lines)
                    for line in lines
                    {
                        //print(line)
                        var values:[String] = []
                        if line != "" {
                            // For a line with double quotes
                            // we use NSScanner to perform the parsing
                            
                            if line.range(of: "\"") != nil
                            {
                                var textToScan:String = line
                                var value:NSString?
                                var textScanner:Scanner = Scanner(string: textToScan)
                                while textScanner.string != "" {
                                    
                                    if (textScanner.string as NSString).substring(to: 1) == "\""
                                    {
                                        textScanner.scanLocation += 1
                                        textScanner.scanUpTo("\"", into: &value)
                                        textScanner.scanLocation += 1
                                    }
                                    else
                                    {
                                        textScanner.scanUpTo(delimiter, into: &value)
                                    }
                                    
                                    // Store the value into the values array
                                    
                                    values.append(value as! String)
                                    
                                    // Retrieve the unscanned remainder of the string
                                    if textScanner.scanLocation < textScanner.string.characters.count {
                                        textToScan = (textScanner.string as NSString).substring(from: textScanner.scanLocation + 1)
                                    } else {
                                        textToScan = ""
                                    }
                                    textScanner = Scanner(string: textToScan)
                                }
                                
                                // For a line without double quotes, we can simply separate the string
                                // by using the delimiter (e.g. comma)
                            } else  {
                                values = line.components(separatedBy: delimiter)
                            }
                            
                            //////print(values)
                            // Put the values into the tuple and add it to the items array
                            let workOut = (id: values[0], name: values[1], exerciseType:  values[2], difficultyLevel:  values[3], equipmentType:  values[4],muscleTargeted: values[5], description: values[6], benefits: values[7], wrokoutTime: values[8], image: values[9], animationUrl: values[10], videoUrl: values[11])
                            stations.append(workOut)
                        }
                    }
                }
            }catch{
            }
            return stations
        }else{
            return []
        }
    }
    
    private func parseStateCSV() -> [(stateId:String, stateName:String, stateCode: String, status: String, created:String, modified:String)] {
        // Load the CSV file and parse it
        
        if let pathForCSV = Bundle.main.path(forResource: "service_hub_state", ofType: "csv"){
            let csvURL = URL.init(fileURLWithPath: pathForCSV)
            
            let delimiter = ","
            var stations:[(stateId:String, stateName:String, stateCode: String, status: String, created:String, modified:String)] = []
            
            do{
                let data = try Data(contentsOf: csvURL)
                if let content =  String(data: data, encoding: String.Encoding.utf8){
                    //existing code
                    let lines:[String] = content.components(separatedBy: NSCharacterSet.newlines) as [String]
                    
                    for line in lines {
                        var values:[String] = []
                        if line != "" {
                            // For a line with double quotes
                            // we use NSScanner to perform the parsing
                            
                            if line.range(of: "\"") != nil {
                                var textToScan:String = line
                                var value:NSString?
                                var textScanner:Scanner = Scanner(string: textToScan)
                                while textScanner.string != "" {
                                    
                                    if (textScanner.string as NSString).substring(to: 1) == "\"" {
                                        textScanner.scanLocation += 1
                                        textScanner.scanUpTo("\"", into: &value)
                                        textScanner.scanLocation += 1
                                    } else {
                                        textScanner.scanUpTo(delimiter, into: &value)
                                    }
                                    
                                    // Store the value into the values array
                                    values.append(value as! String)
                                    
                                    // Retrieve the unscanned remainder of the string
                                    if textScanner.scanLocation < textScanner.string.characters.count {
                                        textToScan = (textScanner.string as NSString).substring(from: textScanner.scanLocation + 1)
                                    } else {
                                        textToScan = ""
                                    }
                                    textScanner = Scanner(string: textToScan)
                                }
                                
                                // For a line without double quotes, we can simply separate the string
                                // by using the delimiter (e.g. comma)
                            } else  {
                                values = line.components(separatedBy: delimiter)
                            }
                            //////print(values)
                            // Put the values into the tuple and add it to the items array
                            let state = (stateId:values[0], stateName:values[1], stateCode: values[2], status: values[3], created:values[4], modified:values[5])
                            stations.append(state)
                        }
                    }
                }
            }catch{
            }
            return stations
        }else{
            return []
        }
    }
    /*
     private func parseRules() -> [(ruleNumber:String, ruleTitle:String, ruleDescription:String)]
     {
     // Load the CSV file and parse it
     
     if let pathForCSV = Bundle.main.path(forResource: "FloridaRulesOfCivilProcedure", ofType: "csv"){
     let csvURL = URL.init(fileURLWithPath: pathForCSV)
     
     let delimiter = "\t"
     var stations:[(ruleNumber:String, ruleTitle:String, ruleDescription:String)] = []
     
     do{
     let data = try Data(contentsOf: csvURL)
     if let content =  String(data: data, encoding: String.Encoding.utf8){
     //existing code
     let lines:[String] = content.components(separatedBy: NSCharacterSet.newlines) as [String]
     
     for line in lines {
     var values:[String] = []
     if line != "" {
     // For a line with double quotes
     // we use NSScanner to perform the parsing
     
     if line.range(of: "\"") != nil
     {
     var textToScan:String = line
     var value:NSString?
     var textScanner:Scanner = Scanner(string: textToScan)
     while textScanner.string != "" {
     
     if (textScanner.string as NSString).substring(to: 1) == "\"" {
     textScanner.scanLocation += 1
     textScanner.scanUpTo("\"", into: &value)
     textScanner.scanLocation += 1
     } else {
     textScanner.scanUpTo(delimiter, into: &value)
     }
     
     // Store the value into the values array
     values.append(value as! String)
     
     // Retrieve the unscanned remainder of the string
     if textScanner.scanLocation < textScanner.string.characters.count
     {
     textToScan = (textScanner.string as NSString).substring(from: textScanner.scanLocation + 1)
     } else {
     textToScan = ""
     }
     textScanner = Scanner(string: textToScan)
     }
     
     // For a line without double quotes, we can simply separate the string
     // by using the delimiter (e.g. comma)
     }
     else
     {
     values = line.components(separatedBy: delimiter)
     }
     //////print(values)
     // Put the values into the tuple and add it to the items array
     
     let state = (ruleNumber:values[2], ruleTitle:values[3], ruleDescription:values[4])
     
     stations.append(state)
     }
     }
     }
     }catch{
     }
     return stations
     }else{
     return []
     }
     }
     */
    private func parseZipCSV() -> [(zipId:String,   stateId:String, countryId:String, cityId:String, zipCode: String, status:String,  created:String, modified:String)]
    {
        // Load the CSV file and parse it
        
        if let pathForCSV = Bundle.main.path(forResource: "service_hub_zip", ofType: "csv"){
            let csvURL = URL.init(fileURLWithPath: pathForCSV)
            
            let delimiter = ","
            var stations:[(zipId:String,   stateId:String, countryId:String, cityId:String, zipCode: String, status:String,  created:String, modified:String)] = []
            
            do{
                let data = try Data(contentsOf: csvURL)
                if let content =  String(data: data, encoding: String.Encoding.utf8){
                    //existing code
                    let lines:[String] = content.components(separatedBy: NSCharacterSet.newlines) as [String]
                    
                    for line in lines {
                        var values:[String] = []
                        if line != "" {
                            // For a line with double quotes
                            // we use NSScanner to perform the parsing
                            
                            if line.range(of: "\"") != nil
                            {
                                var textToScan:String = line
                                var value:NSString?
                                var textScanner:Scanner = Scanner(string: textToScan)
                                while textScanner.string != "" {
                                    
                                    if (textScanner.string as NSString).substring(to: 1) == "\"" {
                                        textScanner.scanLocation += 1
                                        textScanner.scanUpTo("\"", into: &value)
                                        textScanner.scanLocation += 1
                                    } else {
                                        textScanner.scanUpTo(delimiter, into: &value)
                                    }
                                    
                                    // Store the value into the values array
                                    values.append(value as! String)
                                    
                                    // Retrieve the unscanned remainder of the string
                                    if textScanner.scanLocation < textScanner.string.characters.count
                                    {
                                        textToScan = (textScanner.string as NSString).substring(from: textScanner.scanLocation + 1)
                                    } else {
                                        textToScan = ""
                                    }
                                    textScanner = Scanner(string: textToScan)
                                }
                                
                                // For a line without double quotes, we can simply separate the string
                                // by using the delimiter (e.g. comma)
                            }
                            else
                            {
                                values = line.components(separatedBy: delimiter)
                            }
                            //////print(values)
                            // Put the values into the tuple and add it to the items array
                            
                            let state = (zipId:values[0],   stateId:values[1], countryId:values[2], cityId:values[3], zipCode: values[4], status:values[5],  created:values[6], modified:values[7])
                            
                            stations.append(state)
                        }
                    }
                }
            }catch{
            }
            return stations
        }else{
            return []
        }
    }
    
    
    //MARK: Chat History Manage
    
    func getChatHistoryList() -> [CRMChat]
    {
        let usersFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "ChatHistory")
        usersFetchRequest.entity = NSEntityDescription.entity(forEntityName: "ChatHistory", in: self.managedObjectContext)
        do {
            if let serviceDataFetch = try self.managedObjectContext.fetch(usersFetchRequest) as? [ChatHistory]
            {
                var aryChatData:[CRMChat] = []
                for users in serviceDataFetch
                {
                    aryChatData.append(CRMChat(withCoreDataObject: users))
                }
                return aryChatData
            }else{
                return []
            }
        }catch{
            return []
        }
    }
    
    func saveDataForSingleChat(_ dict : [String : AnyObject])
    {
        let entity = NSEntityDescription.entity(forEntityName: "ChatHistory", in: self.managedObjectContext)
        let chatObject = ChatHistory(entity: entity!, insertInto: managedObjectContext)
        
        if dict["chat_id"] != nil {
            chatObject.chat_id = dict["chat_id"] as? String
        }
        if dict["create_date"] != nil {
            chatObject.create_date = dict["create_date"] as? String
        }
        if dict["message"] != nil {
            chatObject.message = dict["message"] as? String
        }
        if dict["read_status"] != nil {
            chatObject.read_status = dict["read_status"] as? String
        }
        
        
        
        if dict["reciver_id"] != nil {
            chatObject.reciver_id = dict["reciver_id"] as? String
        }
        if dict["sender_id"] != nil {
            chatObject.sender_id = dict["sender_id"] as? String
        }
        
        if chatObject.sender_id == CRMUser.shared.userId {
            chatObject.read_status = "1"
        }
        else{
            let visible : UINavigationController = appDelegate.centerViewController as! UINavigationController
            if visible.visibleViewController is LGChatController {
                let objChatListViewController: LGChatController = visible.visibleViewController as! LGChatController
                ////print(objChatListViewController.objChatUserDetail?.user_id ?? "null Value")
                ////print(chatObject.sender_id ?? "blank")
                if objChatListViewController.objChatUserDetail != nil && objChatListViewController.objChatUserDetail?.user_id == chatObject.sender_id {
                    chatObject.read_status = "1"
                }
                else{
                    chatObject.read_status = "0"
                }
            }
            else{
                chatObject.read_status = "0"
            }
            
        }
        
        
        if self.addedNewChatMessage != nil
        {
            let crmChat : CRMChat = CRMChat(withCoreDataObject: chatObject)
            self.addedNewChatMessage!(crmChat)
        }
        if self.updateChatUnreadCount != nil
        {
            let crmChat : CRMChat = CRMChat(withCoreDataObject: chatObject)
            self.updateChatUnreadCount!(crmChat)
        }
        
        
        // manageObj.setValuesForKeys(data)
        do{
            // try self.managedObjectContext.save()
            try chatObject.managedObjectContext?.save()
        }catch{
            ////print("Failed to save city object :: At Index = \(index)")
        }
        ////print("Data saved")
    }
    func getUnreadCountForChatHistory(objSenderId: String) -> String {
        //NSPredicate(format: "%K == %@ AND %K == %@", argumentArray:["key1", "value1", "key2", "value2"])
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ChatHistory")
        fetchRequest.predicate = NSPredicate(format: "sender_id = %@ AND read_status = %@", objSenderId,"0")
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            
            return "\(records.count)"
        }
        catch {
            ////print(error)
        }
        return "0"
    }
    func updateChatHistoryforReadStatus(objSenderId: String) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ChatHistory")
        fetchRequest.predicate = NSPredicate(format: "sender_id = %@ AND read_status = %@", objSenderId,"0")
        
        do {
            let records = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            
            for record in records {
                ////print(record.value(forKey: "message") ?? "no name")
                ////print(record.value(forKey: "sender_id") ?? "no name")
                
                record.setValue("1", forKey: "read_status")
                
                do{
                    try record.managedObjectContext?.save()
                }catch{
                    ////print("Failed to save city object :: At Index = \(index)")
                }
                
            }
            
        } catch {
            ////print(error)
        }
    }
    func insertChatHistoryinDb(aryChatHistory : Array<Any> , isOfflineMessages : Bool) -> Void
    {
        var arrOfOfflineChat : [CRMChat] = []
        for index in 0..<aryChatHistory.count
        {
            // Create Entity
            if let entity = NSEntityDescription.entity(forEntityName: "ChatHistory", in: self.managedObjectContext)
            {
                
                // Initialize Record
                let dict:[String:Any] = aryChatHistory[index] as! [String : Any];
                
                
                let chatObject = ChatHistory(entity: entity, insertInto: self.managedObjectContext)
                //chatObject.setValuesForKeys(dict)
                if (dict["id"] as? Int) != nil
                {
                    chatObject.chat_id = String(describing: dict["id"] as! Int) // dict["id"] as? String
                }
                if (dict["create_date"] as? String) != nil {
                    chatObject.create_date = dict["create_date"] as? String
                }
                if (dict["message"] as? String) != nil {
                    
                    chatObject.message = dict["message"] as? String
                }
                chatObject.read_status = "1"
                if (dict["read_status"] as? Int) != nil
                {
                    chatObject.read_status = String(describing: dict["read_status"] as! Int)
                }
                if  isOfflineMessages {
                    chatObject.read_status = "0"
                }
                if (dict["reciver_id"] as? Int) != nil{
                    chatObject.reciver_id = String(describing: dict["reciver_id"] as! Int)
                }
                if (dict["sender_id"] as? Int) != nil{
                    chatObject.sender_id = String(describing: dict["sender_id"] as! Int)
                }
                // */
                // ////print(chatObject.chat_id ?? "no")
                let crmChat : CRMChat = CRMChat(withCoreDataObject: chatObject)
                arrOfOfflineChat.append(crmChat)
                
                do{
                    try chatObject.managedObjectContext?.save()
                }catch{
                    ////print("Failed to save city object :: At Index = \(index)")
                }
                
                
                //                if self.updateChatUnreadCount != nil
                //                {
                //                    let crmChat : CRMChat = CRMChat(withCoreDataObject: chatObject)
                //                    self.updateChatUnreadCount!(crmChat)
                //                }
            }else{
                ////print("Failed to create entity :: At Index = \(index)")
            }
        }
        if self.gotNewMessages != nil
        {
            self.gotNewMessages!(arrOfOfflineChat)
        }
        let visible : UINavigationController = appDelegate.centerViewController as! UINavigationController
        if visible.visibleViewController is ChatListViewController {
            //In LG chat Controller
            let chatList : ChatListViewController = visible.visibleViewController as! ChatListViewController
            chatList.reloadTableWhenGotNewMessages()
        }
    }
    
    
    
    func deleteData(entityToFetch: String, completion: @escaping(_ returned: Bool) ->()) {
        
        if let fetchRequest = self.managedObjectModel.fetchRequestTemplate(forName: entityToFetch)
        {
            do {
                let results = try self.managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
                for result in results
                {
                    self.managedObjectContext.delete(result)
                }
                try self.managedObjectContext.save()
                completion(true)
            } catch {
                completion(false)
                ////print("fetch error -\(error.localizedDescription)")
            }
        }
    }
    func deleteAllRecods(fromEntityName entityName:String) -> Void
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do
        {
            try self.persistentStoreCoordinator.execute(deleteRequest, with: self.managedObjectContext)
        }
        catch
        {
            ////print("Error:: Records is not found for \(entityName)")
        }
        /*
         fetchRequest.entity = NSEntityDescription.entity(forEntityName: entityName, in: self.managedObjectContext)
         
         do {
         if let serviceDataFetch = try self.managedObjectContext.fetch(fetchRequest) as? [NSManagedObject]
         {
         
         for users in serviceDataFetch
         {
         self.managedObjectContext.delete(users)
         
         }
         
         try self.managedObjectContext.save()
         ////print("Delete data in \(entityName) Table")
         
         }else
         {
         ////print("Error:: Records is not found for \(entityName)")
         }
         }
         catch
         {
         ////print("Error:: Records is not deleted in \(entityName)")
         
         }
         */
        
    }
    
    func insertNotificationListinDb(arrNotificationlist : NSArray) -> Void
    {
        
        for index in 0..<arrNotificationlist.count
        {
            // Create Entity
            if let entity = NSEntityDescription.entity(forEntityName: "NotificationList", in: self.managedObjectContext)
            {
                // Initialize Record
                let dict:[String:Any] = arrNotificationlist[index] as! [String : Any];
                if  dict["notification_id"] != nil
                {
                    if self.checkNotificationExistInCoreData(notificationID: dict["notification_id"] as! String)
                    {
                        let notificationObject = NotificationList(entity: entity, insertInto: self.managedObjectContext)
                        if dict["created"] != nil {
                            notificationObject.created = dict["created"] as! String?
                        }
                        if dict["data"] != nil {
                            notificationObject.data = dict["data"] as! String?
                        }
                        if dict["id"] != nil {
                            notificationObject.id = dict["id"] as! String?
                        }
                        if dict["message"] != nil {
                            notificationObject.message = dict["message"] as! String?
                        }
                        if dict["notification_id"] != nil {
                            notificationObject.notification_id = dict["notification_id"] as! String?
                        }
                        if dict["title"] != nil {
                            notificationObject.title = dict["title"] as! String?
                        }
                        if dict["type"] != nil {
                            notificationObject.type = dict["type"] as! String?
                        }
                        if dict["user_id"] != nil {
                            notificationObject.user_id = dict["user_id"] as! String?
                        }
                        do{
                            try notificationObject.managedObjectContext?.save()
                        }catch{
                            ////print("Failed to save city object :: At Index = \(index)")
                        }
                    }
                    else{
                        ////print("already exist")
                    }
                }
            }else{
                ////print("Failed to create entity :: At Index = \(index)")
            }
        }
    }
    //MARK:
    //MARK: Chat User List
    func insertChatUserListinDb(arrChatUsers : Array<Any>) -> Void
    {
        
        for index in 0..<arrChatUsers.count
        {
            // Create Entity
            if let entity = NSEntityDescription.entity(forEntityName: "ChatUserList", in: self.managedObjectContext)
            {
                // Initialize Record
                let dict:[String:Any] = arrChatUsers[index] as! [String : Any];
                if let value = dict["user_id"] as? String
                {
                    if self.checkChatUserExistInCoreData(fromuserID: value)
                    {
                        let chatObject = ChatUserList(entity: entity, insertInto: self.managedObjectContext)
                        //chatObject.setValuesForKeys(dict)
                        if (dict["fname"] as? String) != nil
                        {
                            
                            if  let value = dict["fname"] as? String
                            {
                                ////print(value)
                                chatObject.fname = value
                            }
                        }
                        if (dict["is_online"] as? String) != nil {
                            chatObject.is_online = dict["is_online"] as? String
                            
                        }
                        if (dict["lname"] as? String) != nil {
                            chatObject.lname = dict["lname"] as? String
                        }
                        if (dict["socket_id"] as? Int) != nil
                        {
                            chatObject.socket_id = dict["socket_id"] as? String
                        }
                        if (dict["user_id"] as? String) != nil{
                            //  ////print(String(describing: dict["user_id"]))
                            // chatObject.user_id = String(describing: dict["user_id"])
                            ////print(dict["user_id"] as? String ?? "nil")
                            if  let value = dict["user_id"] as? String
                            {
                                ////print(value)
                                chatObject.user_id = value
                            }
                        }
                        if (dict["unReadChatCount"] as? Int) != nil{
                            
                            chatObject.unReadChatCount = dict["unReadChatCount"] as? String
                        }
                        
                        do{
                            try chatObject.managedObjectContext?.save()
                        }catch{
                            ////print("Failed to save city object :: At Index = \(index)")
                        }
                        
                    }
                    else{
                        ////print("already exist")
                    }
                }
            }else{
                ////print("Failed to create entity :: At Index = \(index)")
            }
        }
        
    }
    func getChatUserList() -> [CRMChatUser]
    {
        let usersFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "ChatUserList")
        usersFetchRequest.entity = NSEntityDescription.entity(forEntityName: "ChatUserList", in: self.managedObjectContext)
        do {
            if let serviceDataFetch = try self.managedObjectContext.fetch(usersFetchRequest) as? [ChatUserList]
            {
                var aryChatData:[CRMChatUser] = []
                for users in serviceDataFetch
                {
                    aryChatData.append(CRMChatUser(withCoreDataObject: users))
                }
                return aryChatData
            }else{
                return []
            }
        }catch{
            return []
        }
    }
    func getUserDetailanotherWay(id1 : String, id2 : String, date : String) -> [CRMChat]{
        let usersFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ChatHistory")
        usersFetchRequest.predicate = NSPredicate(format: "((sender_id = %@ AND reciver_id = %@) or (sender_id = %@ AND reciver_id = %@)) AND create_date < %@", id1,id2,id2,id1,date)
        
        let sortDescriptor = NSSortDescriptor(key: "create_date", ascending: false)
        usersFetchRequest.sortDescriptors = [sortDescriptor]
        
        usersFetchRequest.fetchLimit = 20
        usersFetchRequest.fetchOffset =  0
        ////print(usersFetchRequest.predicate ?? "wrong predicate")
        
        do {
            if let serviceDataFetch = try self.managedObjectContext.fetch(usersFetchRequest) as? [ChatHistory]
            {
                var aryChatData:[CRMChat] = []
                for users in serviceDataFetch
                {
                    //aryChatData.append(CRMChat(withCoreDataObject: users))
                    
                    aryChatData.insert(CRMChat(withCoreDataObject: users), at:0)
                    
                }
                
                return aryChatData
            }else{
                return []
            }
        }catch{
            return []
        }
        
        
    }
    func getChatuserFullResponce(objSenderId:String) ->CRMChatUser
    {
        
        let crmCht : CRMChatUser = CRMChatUser()
        let localNotificationFetch = NSFetchRequest<NSFetchRequestResult>.init(entityName: "ChatUserList")
        localNotificationFetch.entity = NSEntityDescription.entity(forEntityName: "ChatUserList", in: self.managedObjectContext)
        let predicate = NSPredicate.init(format: "user_id CONTAINS[c] %@", objSenderId)
        localNotificationFetch.predicate = predicate
        
        ////print(predicate)
        
        do {
            if let fetchedNotifications = try self.managedObjectContext.fetch(localNotificationFetch) as? [ChatUserList]
            {
                if fetchedNotifications.count > 0{
                    let firstObj = fetchedNotifications[0]
                    let crmChatUser : CRMChatUser = CRMChatUser.init(withCoreDataObject: firstObj)
                    return crmChatUser
                }
                else{
                    
                    return crmCht
                }
            }
        } catch {
            fatalError("Failed to fetch NotificationList: \(error)")
        }
        
        
        return crmCht
        
    }
    
    func checkChatUserExistInCoreData(fromuserID userId:String) -> Bool
    {
        let localNotificationFetch = NSFetchRequest<NSFetchRequestResult>.init(entityName: "ChatUserList")
        localNotificationFetch.entity = NSEntityDescription.entity(forEntityName: "ChatUserList", in: self.managedObjectContext)
        let predicate = NSPredicate.init(format: "user_id == %@", userId)
        localNotificationFetch.predicate = predicate
        
        ////print(predicate)
        
        do {
            if let fetchedNotifications = try self.managedObjectContext.fetch(localNotificationFetch) as? [ChatUserList]
            {
                let firstObj = fetchedNotifications
                if firstObj.count > 0
                {
                    return false
                }
                else
                {
                    return true
                }
                //  ////print(firstObj.fname)
            }
        } catch {
            fatalError("Failed to fetch NotificationList: \(error)")
        }
        return false
    }
    
    func checkNotificationExistInCoreData(notificationID notID:String) -> Bool
    {
        let localNotificationFetch = NSFetchRequest<NSFetchRequestResult>.init(entityName: "NotificationList")
        localNotificationFetch.entity = NSEntityDescription.entity(forEntityName: "NotificationList", in: self.managedObjectContext)
        let predicate = NSPredicate.init(format: "notification_id == %@", notID)
        localNotificationFetch.predicate = predicate
        
        ////print(predicate)
        
        do {
            if let fetchedNotifications = try self.managedObjectContext.fetch(localNotificationFetch) as? [NotificationList]
            {
                let firstObj = fetchedNotifications
                if firstObj.count > 0
                {
                    return false
                }
                else
                {
                    return true
                }
                //  ////print(firstObj.fname)
            }
        } catch {
            fatalError("Failed to fetch NotificationList: \(error)")
        }
        return false
    }
    func getNotificationList() -> [NotificationList]
    {
        let usersFetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "NotificationList")
        usersFetchRequest.entity = NSEntityDescription.entity(forEntityName: "NotificationList", in: self.managedObjectContext)
        do {
            if let serviceDataFetch = try self.managedObjectContext.fetch(usersFetchRequest) as? [NotificationList]
            {
                var aryNotificationData:[NotificationList] = []
                for notification in serviceDataFetch
                {
                    aryNotificationData.append(notification)
                }
                return aryNotificationData
            }else{
                return []
            }
        }catch{
            return []
        }
    }
    
}
