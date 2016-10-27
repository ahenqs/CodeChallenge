//
//  ContactsTableViewController.swift
//  CodeChallenge
//
//  Created by André Henrique da Silva on 10/12/15.
//  Copyright © 2015 André Henrique da Silva. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON

class ContactsTableViewController: UITableViewController, ContactDelegate, WebServiceDelegate, DBHelperDelegate, TableViewDelegate {
    
    var contacts = [Contact]()
    var dataSource: TableViewDataSource?
    var selectedIndexPath: IndexPath?
    var wsContacts: WebService!
    var loading: Loading = Loading()
    var dbHelper = DBHelper()
    var animate = true
    var hasConnection:Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbHelper.delegate = self

        loadInterface()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateTable()
        
        animate = true
    }
    
    func animateTable() {

        loadDataFromDB()
        
        if (animate){
        
            let cells = tableView.visibleCells
            let tableHeight: CGFloat = tableView.bounds.size.height
            
            for i in cells {
                let cell: UITableViewCell = i as UITableViewCell
                cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
            }
            
            var index = 0
            
            for a in cells {
                let cell: UITableViewCell = a as UITableViewCell
                UIView.animate(withDuration: 1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveLinear, animations: {
                    cell.transform = CGAffineTransform(translationX: 0, y: 0)
                    }, completion: nil)
                
                index += 1
            }
        }
    }
    
    //loads basic interface components
    func loadInterface(){
        let addButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ContactsTableViewController.addNewContact(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        
        //removes space before empty cell separators
        self.tableView.separatorInset = UIEdgeInsets.zero
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // + sign action on the right top of navigation bar
    @IBAction func addNewContact(_ sender: UIButton) {
        self.performSegue(withIdentifier: "contact", sender: nil)
        self.animate = false
    }
    
    //shows a simple alert to the user
    func showAlert(_ title: String, message: String, buttonTitle: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: nil))
        
        let popOver = alertController.popoverPresentationController
        popOver?.barButtonItem = self.navigationItem.rightBarButtonItem
        popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
        alertController.modalPresentationStyle = UIModalPresentationStyle.popover
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - TableViewDelegate methods

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "contact", sender: self.contacts[(indexPath as NSIndexPath).row])
        self.animate = false
    }

    // MARK: Navigation methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "contact"){
            
            let editVC = segue.destination as! ContactEditViewController
            
            if (sender != nil){
                editVC.contact = sender as! Contact
            }
            
            editVC.delegate = self
            
        }
    }
    
    // MARK: Delete Contact methods
    
    //dialog before deleting a contact
    func confirmDelete(_ contact: Contact) {
        let alertController = UIAlertController(title: "Delete Contact", message: "Are you sure you want to permanently delete \(contact.name)?", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handleDeleteContact)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelDeleteContact)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        let popOver = alertController.popoverPresentationController
        popOver?.barButtonItem = self.navigationItem.rightBarButtonItem
        popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
        alertController.modalPresentationStyle = UIModalPresentationStyle.popover
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //deleting a contact
    func handleDeleteContact(_ alertAction: UIAlertAction!) -> Void {
        if let indexPath = self.selectedIndexPath {
            
            let contact: Contact = self.contacts[(indexPath as NSIndexPath).row]
            
            if let error = dbHelper.removeContact(contact) {
                
                showAlert("Hey!", message: "Error deleting data: \(error.userInfo)", buttonTitle: "OK")
                
            } else {
                
                loadDataFromDB()
                
                self.selectedIndexPath = nil
            }
            
        }
    }
    
    //user cancels deleting a contact
    func cancelDeleteContact(_ alertAction: UIAlertAction!) {
        self.selectedIndexPath = nil
    }
    
    // MARK: PersonDelegate methods
    
    //right after saving a contact in Contact Editi View Controller
    func contactDidEndEditing(_ contact: Contact, viewController: UIViewController) {
        saveContact(contact)
    }

    // MARK: CoreData methods
    
    //refreshes datasource for tableview
    func refreshDataSource(){
        
        self.dataSource = TableViewDataSource(items: self.contacts as NSArray, cellIdentifier: "cell", configureBlock: { (cell, item) -> () in
            
            if let actualCell = cell as? ContactTableViewCell {
                if let actualContact = item as? Contact {
                    actualCell.configure(actualContact)
                }
            }
            
        })
        
        self.dataSource?.delegate = self
        
        self.tableView.dataSource = self.dataSource
    }
    
    //loads all contacts from database
    func loadDataFromDB(){
        
        self.contacts = dbHelper.allContacts()
        
        if (self.contacts.count > 0){
            
            self.navigationItem.leftBarButtonItem = self.editButtonItem
            
            let total = self.contacts.count
            
            self.title = total == 1 ? "1 Contact" : "\(total) Contacts"
            
        } else {
            
            self.title = "Contacts"
            
            self.navigationItem.leftBarButtonItem = nil
            
            self.perform(#selector(ContactsTableViewController.confirmDownload), with: nil, afterDelay: 1.0)
        }
        
        refreshDataSource()
        
        self.tableView.reloadData()
    }
    
    //saves a contact to database
    func saveContact(_ contact: Contact){
        
        if let error = dbHelper.save(contact) {
            
            showAlert("Hey!", message: "Error saving data: \(error.userInfo)", buttonTitle: "OK")

        } else {
            
            loadDataFromDB()
        }
    }
    
    // MARK: Server methods
    
    //dialog to offer download of contacts from server
    func confirmDownload() {
        let alertController = UIAlertController(title: "Download Contacts", message: "Do you want to download contacts from server?", preferredStyle: .actionSheet)
        
        let downloadAction = UIAlertAction(title: "Yes, download now", style: .default, handler: handleDownloadFromServer)
        let cancelAction = UIAlertAction(title: "No, download later", style: .cancel, handler: cancelDownloadFromServer)

        alertController.addAction(downloadAction)
        alertController.addAction(cancelAction)
        
        let popOver = alertController.popoverPresentationController
        popOver?.barButtonItem = self.navigationItem.rightBarButtonItem
        popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
        alertController.modalPresentationStyle = UIModalPresentationStyle.popover

        self.present(alertController, animated: true, completion: nil)
    }
    
    //starts downloading contacts from server
    func handleDownloadFromServer(_ alertAction: UIAlertAction!) -> Void {
    
        if (Reachability.isConnectedToNetwork()){
        
            self.loading.showLoading(self.view)
            
            self.wsContacts = WebService()
            self.wsContacts.delegate = self
            
            self.wsContacts.get(Constants.kServer)
        } else {
            
            showAlert("Hey!", message: "No internet connection available. Check your settings.", buttonTitle: "OK")
            
        }
        
    }
    
    //user dimisses download dialog and gets a reminder he/she can go to settings
    func cancelDownloadFromServer(_ alertAction: UIAlertAction!) {
        //show message to go to Settings
        showAlert("Hey!", message: "You can always download contacts from server by clicking on\nSettings > Download from Server.", buttonTitle: "OK")
    }
    
    // MARK: WebServiceDelegate methods
    
    func connectionSucceded(_ data: JSON, instance: AnyObject) {
        
        self.loading.hideLoading(self.view)
        
        dbHelper.updateWithData(data, controller: self)
    }
    
    func connectionFailed(_ data: NSDictionary, instance: AnyObject) {
        
        self.loading.hideLoading(self.view)
        
        //there could be a message here <o/
    }
    
    // MARK: DBHelperDelegate methods
    
    func didUpdateDatabaseSuccessfully(_ data: JSON, controller: UIViewController) {
        self.loadDataFromDB()
    }
    
    func didErrorOcurred(_ error: NSError, controller: UIViewController) {        
        showAlert("Hey!", message: "Error saving data: \(error.userInfo)", buttonTitle: "OK")
    }
    
    // MARK: TableViewDelegate method
    
    func tableViewDidDeleteRow(_ indexPath: IndexPath) {
        self.selectedIndexPath = indexPath

        let contact: Contact = self.contacts[(indexPath as NSIndexPath).row]

        confirmDelete(contact)
    }
}
