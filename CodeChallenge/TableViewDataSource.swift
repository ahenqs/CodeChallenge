//
//  TableViewDataSource.swift
//  CodeChallenge
//
//  Created by André Henrique da Silva on 10/12/15.
//  Copyright © 2015 André Henrique da Silva. All rights reserved.
//

import UIKit

public typealias TableViewCellConfigureBlock = (_ cell: UITableViewCell, _ item: AnyObject?) -> ()

public protocol TableViewDelegate: class {
    func tableViewDidDeleteRow(_ indexPath: IndexPath)
}

open class TableViewDataSource: NSObject, UITableViewDataSource {
    
    var items: NSArray = []
    var itemIdentifier: String?
    var configureCellBlock: TableViewCellConfigureBlock?
    var delegate: TableViewDelegate?
    
    init(items: NSArray, cellIdentifier: String, configureBlock: @escaping TableViewCellConfigureBlock) {
        self.items = items
        self.itemIdentifier = cellIdentifier
        self.configureCellBlock = configureBlock
        super.init()
    }

    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.itemIdentifier!, for: indexPath) 
        
        let item: AnyObject = self.itemAtIndexPath(indexPath)
        
        if (self.configureCellBlock != nil){
            self.configureCellBlock!(cell, item)
        }
        
        return cell
    }
    
    func itemAtIndexPath(_ indexPath: IndexPath) -> AnyObject {
        return self.items[(indexPath as NSIndexPath).row] as AnyObject
    }
    
  open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.delegate?.tableViewDidDeleteRow(indexPath)
        }
    }
    
}
