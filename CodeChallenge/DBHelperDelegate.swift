//
//  DatabaseDelegate.swift
//  CodeChallenge
//
//  Created by André Henrique da Silva on 10/12/15.
//  Copyright © 2015 André Henrique da Silva. All rights reserved.
//

import UIKit
import SwiftyJSON

public protocol DBHelperDelegate: class {
    
    func didUpdateDatabaseSuccessfully(_ data: JSON, controller: UIViewController)
    func didErrorOcurred(_ error: NSError, controller: UIViewController)
}
