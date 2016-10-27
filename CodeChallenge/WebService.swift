//
//  WebService.swift
//  CodeChallenge
//
//  Created by André Henrique da Silva on 10/12/15.
//  Copyright © 2015 André Henrique da Silva. All rights reserved.
//

import Foundation
import SwiftyJSON

public protocol WebServiceDelegate {
    func connectionSucceded(_ data:JSON, instance:AnyObject)
    func connectionFailed(_ data:NSDictionary, instance:AnyObject)
}

open class WebService: NSObject, NSURLConnectionDataDelegate {
    
    let URL = "http://192.168.1.34/";
//    let URL = "http://localhost/";
    var data = NSMutableData()
    var delegate:WebServiceDelegate?
    var connection: NSURLConnection!
    
    func post(_ wsName:String, wsParams:AnyObject) {
        var wsName = wsName
        
        if (!wsName.contains("http://")){
            wsName = "\(URL)\(wsName)"
        }
        
        let url = Foundation.URL(string: wsName)
        
        let request:NSMutableURLRequest = NSMutableURLRequest(url:url!)
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: wsParams, options: JSONSerialization.WritingOptions())
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        
        connection = NSURLConnection(request: request as URLRequest, delegate: self, startImmediately: true)
    }
    
    func get(_ urlString:String) {
    
        let url = Foundation.URL(string: urlString)
        
        let request:NSMutableURLRequest = NSMutableURLRequest(url:url!)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        
        connection = NSURLConnection(request: request as URLRequest, delegate: self, startImmediately: true)
    
    }
    
    open func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
        
        self.data = NSMutableData()
    }
    
    open func connection(_ connection: NSURLConnection, didReceive data: Data) {
        
        self.data.append(data)
        
    }
    
    open func connectionDidFinishLoading(_ connection: NSURLConnection) {
    
        self.delegate?.connectionSucceded(JSON(data:self.data as Data), instance: self)
        
    }
    
    open func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        
        self.delegate?.connectionFailed(["error":error.localizedDescription], instance: self)
    }
    
}
