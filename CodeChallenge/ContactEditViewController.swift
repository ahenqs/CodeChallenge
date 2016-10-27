//
//  ContactEditViewController.swift
//  CodeChallenge
//
//  Created by André Henrique da Silva on 10/12/15.
//  Copyright © 2015 André Henrique da Silva. All rights reserved.
//

import UIKit
import CoreData

class ContactEditViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var tfName: UITextField!
    @IBOutlet var tfEmail: UITextField!
    @IBOutlet var tfBorn: UITextField!
    @IBOutlet var tvBio: UITextView!
    @IBOutlet var ivPhoto: UIImageView!
    @IBOutlet var btPhoto: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var fakePlaceholderForTextView: UILabel!
    
    var contact: Contact!
    var delegate: ContactDelegate?
    var popDatePicker : PopDatePicker?
    var keyboardFrame: CGRect = CGRect.null
    
    var blurredImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadInterface()

        //tapping anywhere in the view will end editing
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ContactEditViewController.tap))
        tap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tap)
        
        //observers for keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(ContactEditViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ContactEditViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //loads basic interface
    func loadInterface(){
        
        //add button in top bar
        let addButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(ContactEditViewController.saveTapped(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        
        if (self.contact != nil){
            
            self.title = "Edit Contact"
            
            //Name
            self.tfName.text = contact.value(forKey: "name") as? String
            
            //Email
            self.tfEmail.text = contact.value(forKey: "email") as? String
            
            //Born
            
            if (contact.value(forKey: "born") != nil){
                self.tfBorn.text = ((contact.value(forKey: "born") as? Date)?.toDateOnlyString())!
            } else {
                self.tfBorn.text = ""
            }
            
            //Bio
            self.tvBio.text = contact.value(forKey: "bio") as? String
            
            //hides fake placeholder for bio
            self.fakePlaceholderForTextView.text = ""
            
            //Photo
            if (contact.value(forKey: "photo") != nil){
                
                let p = (contact.value(forKey: "photo") as? Data)!
                
                let image = UIImage(data: p)
                
                self.ivPhoto.image = image
                
                self.blur(image!)
            } else {
                self.view.backgroundColor = Constants.kColorBlue
            }
            
        } else {
            self.title = "New Contact"
            
            self.view.backgroundColor = Constants.kColorBlue
            
            //focus on first textfield
            self.tfName.becomeFirstResponder()
        }
        
        //datepicker for born field
        popDatePicker = PopDatePicker(forTextField: tfBorn)
        
        //improve fields appearence
        
        self.tfName.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        self.tfName.layer.cornerRadius = 5.0
        
        self.tfEmail.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        self.tfEmail.layer.cornerRadius = 5.0
        
        self.tfBorn.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        self.tfBorn.layer.cornerRadius = 5.0
        
        self.tvBio.layer.cornerRadius = 5.0
        self.tvBio.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        
        for view in self.view.subviews {
            if (view.tag != 99){
                view.alpha = 0.0
            }
        }
        
        UIView.animate(withDuration: 0.7, animations: { () -> Void in
            for view in self.view.subviews {
                if (view.tag != 99){
                    view.alpha = 1.0
                }
            }
        }) 

    }
    
    //adds a blurred view with contact's photo behind or light blue if no photo available
    func blur(_ image: UIImage){
        
        if (self.blurredImageView == nil){
            self.blurredImageView = UIImageView(image: image)
            self.blurredImageView.frame = self.view.frame
            self.blurredImageView.contentMode = UIViewContentMode.scaleAspectFill
            self.blurredImageView.clipsToBounds = true
            self.blurredImageView.tag = 99
            
            self.view.addSubview(self.blurredImageView)

            let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.dark)
            let blurView = UIVisualEffectView(effect: darkBlur)
            blurView.frame = self.blurredImageView.bounds
            self.blurredImageView.addSubview(blurView)
            
            self.blurredImageView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            
            self.view.sendSubview(toBack: self.blurredImageView)
            
        } else {
            self.blurredImageView.image = image
        }
        
    }
    
    //user taps anywhere else in the view and keyboard resigns
    func tap(){
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    //user taps on photo to add one or change it
    @IBAction func photoTapped(_ sender: UIButton) {
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = false
        
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    //save button is tapped
    @IBAction func saveTapped(_ sender: UIButton) {
        
        if (formValidate()){
            
            save()
            
        } else {
            let alert = UIAlertController(title: "Hey", message: "Name and E-mail fields are required.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    //validates form, there could be other validations \o>
    func formValidate() -> Bool {
        
        if (tfName.text == "" || tfEmail.text == ""){
            return false
        }
        
        return true
    }
    
    //gather all contact data and sends back to be saved
    func save(){
        
        if (self.contact == nil){// if it's a new contact

            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let managedContext = appDelegate.managedObjectContext
            
            let entity = NSEntityDescription.entity(forEntityName: "Contact", in: managedContext)
            
            self.contact = Contact(entity: entity!, insertInto: managedContext)
            
        }
        
        //Name
        self.contact.setValue(self.tfName.text!, forKey: "name")
        
        //Email
        self.contact.setValue(self.tfEmail.text!, forKey: "email")
        
        //Born
        self.contact.setValue(self.tfBorn.text?.toDate(), forKey: "born")
        
        //Bio
        self.contact.setValue(self.tvBio.text, forKey: "bio")
        
        //Photo
        
        if (self.ivPhoto.image != nil){
        
            let imageData = NSData(data: UIImagePNGRepresentation(self.ivPhoto.image!)!) as Data
            self.contact.setValue(imageData, forKey: "photo")
            
        }
        
        self.delegate?.contactDidEndEditing(self.contact, viewController: self)
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //changes scroll view size so it can scroll properly when smaller devices are used
    func keyboardWillShow(_ notification: Notification) {
        if let info = (notification as NSNotification).userInfo {
            self.keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        }
        
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height + self.keyboardFrame.height)
    }
    
    //scroll view size restored to its regular size
    func keyboardWillHide(_ notification: Notification) {
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
    }
    
    // MARK: UIImagePickerControllerDelegate methods
    
    //photo is selected by user
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        self.ivPhoto.image = image
        
        self.blur(image)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //user dismissed choosing a photo
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: UITextFieldDelegate methods
    
    //what happens when user taps Return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == tfName){
            tfEmail.becomeFirstResponder()
        } else if (textField == tfEmail){
            tfBorn.becomeFirstResponder()
        }
        return true
    }
    
    //if it's the born date field, it shows a datepicker
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if (textField === tfBorn) {

            self.view.endEditing(true)
            
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            let initDate : Date? = formatter.date(from: tfBorn.text!)
            
            let dataChangedCallback : PopDatePicker.PopDatePickerCallback = { (newDate : Date, forTextField : UITextField) -> () in
                
                // here we don't use self (no retain cycle)
                forTextField.text = (newDate.toDateOnlyString() ?? "?") as String
                
            }
            
            popDatePicker!.pick(self, initDate: initDate, dataChanged: dataChangedCallback)
            return false
            
        } else {
            return true
        }
    }
    
    // MARK: UITextViewDelegate methods
    
    //a fake placeholder was created for textview, it's hidden here
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.fakePlaceholderForTextView.text = ""
    }
    
    //a fake placeholder was created for textview, it's shown here when needed
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if (self.tvBio.text == "") {
            self.fakePlaceholderForTextView.text = "Bio"
        }
    }

}
