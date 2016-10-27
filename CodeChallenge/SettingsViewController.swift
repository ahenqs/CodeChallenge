//
//  SettingsViewController.swift
//  CodeChallenge
//
//  Created by André Henrique da Silva on 10/12/15.
//  Copyright © 2015 André Henrique da Silva. All rights reserved.
//

import UIKit
import SwiftyJSON
import LocalAuthentication

class SettingsViewController: UIViewController, WebServiceDelegate, DBHelperDelegate {
    
    @IBOutlet var btDelete: UIButton!
    @IBOutlet var btDownload: UIButton!

    var wsContacts: WebService = WebService()
    var loading: Loading = Loading()
    var dbHelper = DBHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbHelper.delegate = self

        loadInterface()
    }
    
    //basic interface
    func loadInterface(){
        
        self.btDelete.backgroundColor = Constants.kColorGreen
        self.btDelete.setTitleColor(UIColor.white, for: UIControlState())
        
        self.btDownload.backgroundColor = Constants.kColorGreen
        self.btDownload.setTitleColor(UIColor.white, for: UIControlState())
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //user required to use touch ID to download from server \o/
    @IBAction func downloadFromServerTapped(_ sender: UIButton) {
        userAuthenticate(#selector(SettingsViewController.download))
    }
    
    //starts downloading contacts from server
    func download(){

        if (Reachability.isConnectedToNetwork()){
            self.loading.showLoading(self.view)
            
            self.wsContacts = WebService()
            self.wsContacts.delegate = self
            
            self.wsContacts.get(Constants.kServer)
        } else {
            showAlert("Hey!", message: "No internet connection available. Check your settings.", buttonTitle: "OK")
        }
    }
    
    //user required to use touch ID to remove all data from database ^o^
    @IBAction func deleteAll(_ sender: UIButton) {
        
        userAuthenticate(#selector(SettingsViewController.deleteAll as (SettingsViewController) -> () -> ()))
    }
    
    //delete all contacts from database
    func deleteAll(){

        dbHelper.removelAllContacts("Contact", controller: self)
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
    
    func userAuthenticate(_ selector: Selector){
        
        let context = LAContext()
        
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error:nil) {
            
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authentication required to do major updates on your device.", reply: { (success : Bool, error : NSError? ) -> Void in

                    DispatchQueue.main.async(execute: {
                        if success {
                            self.perform(selector)
                        }
                        
                        if error != nil {
                            
                            var message : String
                            var showAlert : Bool
                            
                            switch(error!.code) {
                            case LAError.Code.authenticationFailed.rawValue:
                                message = "There was a problem verifying your identity."
                                showAlert = true
                                break;
                            case LAError.Code.userCancel.rawValue:
                                message = "You pressed cancel."
                                showAlert = false
                                break;
                            case LAError.Code.userFallback.rawValue:
                                message = "You pressed password."
                                showAlert = false
                                break;
                            default:
                                showAlert = false
                                message = "Touch ID may not be configured"
                                break;
                            }
                            
                            if (showAlert){
                                self.showAlert("Hey!", message: message, buttonTitle: "OK")
                            } else {
                                self.showPasswordAlert(selector)
                            }
                            
                        }
                    })
                    
            } as! (Bool, Error?) -> Void)
        } else {
            self.showPasswordAlert(selector)
        }
    }
    
    // MARK: Password Alert
    
    func showPasswordAlert(_ selector: Selector) {
        let alertController = UIAlertController(title: "Touch ID Password", message: "Please enter your password.", preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
            
            if let textField = alertController.textFields?.first as UITextField? {
                if textField.text != "1234"{
                    self.showPasswordAlert(selector)
                } else {
                    self.perform(selector)
                }
            }
        }
        alertController.addAction(defaultAction)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alertController.addTextField { (textField) -> Void in
            
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
            
        }
        
        let popOver = alertController.popoverPresentationController
        popOver?.barButtonItem = self.navigationItem.rightBarButtonItem
        popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
        alertController.modalPresentationStyle = UIModalPresentationStyle.popover
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: WebServiceDelegate methods
    
    func connectionSucceded(_ data: JSON, instance: AnyObject) {
        
        self.loading.hideLoading(self.view)

        dbHelper.updateWithData(data, controller: self)
    
    }
    
    func connectionFailed(_ data: NSDictionary, instance: AnyObject) {
        
        self.loading.hideLoading(self.view)
    }
    
    // MARK: DBHelperDelegate methods
    
    func didUpdateDatabaseSuccessfully(_ data: JSON, controller: UIViewController) {
        
        showAlert("Hey!", message: "Database updated successfully.", buttonTitle: "OK")
    }
    
    func didErrorOcurred(_ error: NSError, controller: UIViewController) {

        showAlert("Hey!", message: "Error updating database: \(error.userInfo)", buttonTitle: "OK")
    }
    
}
