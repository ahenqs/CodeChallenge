//
//  Person.swift
//  CodeChallenge
//
//  Created by André Henrique da Silva on 10/12/15.
//  Copyright © 2015 André Henrique da Silva. All rights reserved.
//

import Foundation
import CoreData

open class Contact: NSManagedObject {
    
    @NSManaged open var name:  String
    @NSManaged open var email: String
    @NSManaged var born:  Date
    @NSManaged var bio:   String
    @NSManaged var photo: Data
    
}
