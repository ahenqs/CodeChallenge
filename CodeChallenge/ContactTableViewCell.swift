//
//  ContactTableViewCell.swift
//  CodeChallenge
//
//  Created by André Henrique da Silva on 10/12/15.
//  Copyright © 2015 André Henrique da Silva. All rights reserved.
//

import UIKit

open class ContactTableViewCell: UITableViewCell {
    
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!

    override open func awakeFromNib() {
        super.awakeFromNib()

        //Removes space before cell separator
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
    }

    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(_ contact: Contact){
        self.nameLabel?.text = contact.value(forKey: "name") as? String
        self.emailLabel?.text = contact.value(forKey: "email") as? String
        
        if let data = contact.value(forKey: "photo") as? Data {
            
            self.photoImageView?.contentMode = UIViewContentMode.scaleAspectFill
            self.photoImageView?.image = UIImage(data: data)
            
            self.photoImageView.layer.cornerRadius = 30.0
        } else {
            self.photoImageView.image = nil
        }
    }

}
