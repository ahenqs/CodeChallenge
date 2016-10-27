//
//  DBHelper.swift
//  CodeChallenge
//
//  Created by André Henrique da Silva on 10/12/15.
//  Copyright © 2015 André Henrique da Silva. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreData

open class DBHelper: NSObject {
    
    open var delegate: DBHelperDelegate?
    open var total = 0
    open var totalUpdated = 0
    
    open var managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    //saves a contact
    func save(_ contact: Contact) -> NSError? {
        
        let managedContext = contact.managedObjectContext
        
        do {
            try managedContext!.save()
            return nil
            
        } catch let error as NSError {
            return error
        }
    }
    
    //lists all contacts
    func allContacts() -> [Contact] {
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Contact")
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            
            let results = try self.managedObjectContext.fetch(fetchRequest)
            
            return results as! [Contact]
            
        } catch {
            return []
        }
        
    }
    
    //saves all downloaded contacts
    func updateWithData(_ data: JSON, controller: UIViewController){
        
        self.total = data.count
        self.totalUpdated = 0
        
        let entity = NSEntityDescription.entity(forEntityName: "Contact", in: self.managedObjectContext)
        
        for (_,dict):(String, JSON) in data {
            
            let contact = Contact(entity: entity!, insertInto: self.managedObjectContext)
            
            contact.name = dict["name"].string!
            contact.email = dict["email"].string!
            
            let born = dict["born"].string!
            
            if let newDate: Date = born.simpleToDate() as Date? {
                contact.born = newDate
            }
            
            contact.bio = dict["bio"].string!
            
            let imageURL:URL = URL(string: dict["photo"].string!)!
            let request: URLRequest = URLRequest(url: imageURL)
            let mainQueue = OperationQueue.main
            
            NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, odata, error) -> Void in
                if error == nil {
                    let image = UIImage(data: odata!)
                    
                    DispatchQueue.main.async(execute: {
                        
                        do {
                            
                            if(image != UIImage() && image != nil){
                                
                                contact.photo = (UIImagePNGRepresentation(image!))!
                            }
                            
                            try self.managedObjectContext.save()
                            
                            self.totalUpdated += 1
                            
                            if (self.total == self.totalUpdated){
                                self.delegate?.didUpdateDatabaseSuccessfully(data, controller: controller)
                            }
                            
                        } catch let error as NSError {
                            
                            self.delegate?.didErrorOcurred(error, controller: controller)
                        }
                        
                    })
                } else {
                    print("Error: \(error!.localizedDescription)")
                    
                    self.delegate?.didErrorOcurred(error! as NSError, controller: controller)
                }
            })
            
        }
    }
    
    //remove a single contact
    func removeContact(_ contact: Contact) -> NSError? {
        let context = contact.managedObjectContext
        context!.delete(contact)
        
        do {
            try context!.save()
            return nil
            
        } catch let error as NSError {
            return error
        }
    }
    
    //removes all contacts from database
    func removelAllContacts(_ tableName: String, controller: UIViewController){
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: tableName, in: self.managedObjectContext)
        fetchRequest.includesPropertyValues = false
        
        let error:NSError?
        
        do {
            if let results = try! self.managedObjectContext.fetch(fetchRequest) as? [NSManagedObject] {
                for result in results {
                    self.managedObjectContext.delete(result)
                }
                
                try self.managedObjectContext.save()
                
                self.delegate?.didUpdateDatabaseSuccessfully(JSON.null, controller: controller)
                
            } else {
                error = NSError(domain: "Error", code: 1, userInfo: ["localizedDescription":"Error updating data."])
                self.delegate?.didErrorOcurred(error!, controller: controller)
            }
        } catch let error as NSError {
            
            self.delegate?.didErrorOcurred(error, controller: controller)
        }
    }

}
