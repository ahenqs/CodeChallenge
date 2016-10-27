//
//  Loading.swift
//  CodeChallenge
//
//  Created by André Henrique da Silva on 10/12/15.
//  Copyright © 2015 André Henrique da Silva. All rights reserved.
//

import UIKit

open class Loading: NSObject {
    
    var alphaView: UIView!
    var spinner: UIActivityIndicatorView!
    
    func showLoading(_ view:UIView){
        alphaView = UIView(frame: view.bounds)
        alphaView.backgroundColor = UIColor.black
        alphaView.alpha = 0.4
        alphaView.layer.zPosition = 10000
        alphaView.tag = Constants.kTagLoading
        
        spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        spinner.hidesWhenStopped = true
        spinner.center = view.center
        spinner.layer.zPosition = 10001
        spinner.startAnimating()
        
        alphaView.addSubview(spinner)
        
        view.addSubview(alphaView)
    }
    
    func hideLoading(_ view:UIView){
        
        if (view.viewWithTag(Constants.kTagLoading) != nil){
            
            spinner.stopAnimating()
            
            alphaView.removeFromSuperview()
        }
    }

}
