//
//  PersonDelegate.swift
//  CodeChallenge
//
//  Created by André Henrique da Silva on 10/12/15.
//  Copyright © 2015 André Henrique da Silva. All rights reserved.
//

import UIKit

public protocol ContactDelegate: class {
    func contactDidEndEditing(_ contact: Contact, viewController: UIViewController)
}

