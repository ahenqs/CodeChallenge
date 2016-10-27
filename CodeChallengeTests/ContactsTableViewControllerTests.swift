//
//  ContactsTableViewControllerTests.swift
//  CodeChallenge
//
//  Created by André Henrique da Silva on 10/14/15.
//  Copyright © 2015 André Henrique da Silva. All rights reserved.
//

import UIKit
import XCTest
@testable import CodeChallenge
import CoreData

class ContactsTableViewControllerTests: XCTestCase {
    
    var viewController: ContactsTableViewController!
    var contact: Contact!
    
    override func setUp() {
        super.setUp()

        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ContactsTableViewController") as! ContactsTableViewController
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entity = NSEntityDescription.entityForName("Contact", inManagedObjectContext: managedContext)
        
        self.contact = Contact(entity: entity!, insertIntoManagedObjectContext: managedContext)
    }
    
    override func tearDown() {

        self.viewController = nil
        self.contact = nil

        super.tearDown()
    }
    
    func testTableView() {
        
        XCTAssertNotNil(viewController.tableView, "Tableview should not be nil")

    }
    
    func testLoadingContactsFromDatabase() {
        
        viewController.dbHelper = MockDBHelper()
        
        viewController.loadDataFromDB()
        
        XCTAssertEqual(viewController.contacts.count, 2, "Should be equals 2")
        
    }
    
    func testSavingContact() {
        
        viewController.dbHelper = MockDBHelper()
        
        XCTAssertNil(viewController.dbHelper.save(self.contact), "Should be nil")
        
    }
    
    func testRemoveContact() {
        
        viewController.dbHelper = MockDBHelper()
        
        XCTAssertNotNil(viewController.dbHelper.removeContact(self.contact), "Should not be nil")
    }
    
    func testStringToDate() {
        
        let dateFromServer = "23/04/2015".toDate()
        
        XCTAssertNotNil(dateFromServer, "Should not be nil!")
        
    }
    
    func testBadStringToDate() {
        
        let dateFromServer = "01/99/2015".toDate()
        
        XCTAssertNil(dateFromServer, "Should be nil!")
        
    }
    
}

class MockDBHelper: DBHelper {
    
    override func allContacts() -> [Contact] {
        
        let contact1: Contact = Contact()
        let contact2: Contact = Contact()
        
        return [contact1, contact2]

    }
    
    override func save(_ contact: Contact) -> NSError? {
        
        let error: NSError? = nil
        
        return error
    }
    
    override func removeContact(_ contact: Contact) -> NSError? {

        return NSError(domain: "Error", code: 1, userInfo: nil)
    }
    
}
