//
//  iOSApiConnection.swift
//  VideoChat
//
//  Created by Rohit Singh on 08/12/15.
//  Copyright © 2015 Home. All rights reserved.
//

import UIKit
import AFNetworking
import Reachability


class iOSApiConnection: NSObject {
    
    // Singleton Object Creation
    static let sharedInstance : iOSApiConnection = {
        let instance = iOSApiConnection()
        return instance
    }()
    
    // Checking the internet Internet Connection
    func isInternetConnected() -> Bool {
        let reach : Reachability =  Reachability.forInternetConnection()
        let netStatus : NetworkStatus = reach.currentReachabilityStatus()
        
        if (netStatus == NetworkStatus.NotReachable)
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    // Making String Request Api Call
    func callStringWebServiceWithUrl(_ apiPath:String,
                                     time : TimeInterval = 60,
                                     methodName:String ,
                                     headers:Dictionary<String,String>?,
                                     params:Dictionary<String, AnyObject>?,
                                     completionHandler:@escaping (_ response: Dictionary<String, Any>?,_ error: NSError?) -> Void)
    {
        print("API Path =>>>>\n\(apiPath as Any)")
        
        if params != nil {
            print("Params =>>>> \n \(params as Any)")
        }
        
        let request : URLRequest = AFHTTPRequestSerializer().request(withMethod: methodName, urlString: apiPath, parameters: params, error: nil) as URLRequest
        
        let session = URLSession.shared
        
        if (iOSApiConnection.sharedInstance.isInternetConnected())
        {
            session.dataTask(with: request, completionHandler: { (data: Data?, response : URLResponse?, err : NSError?) -> Void in
                if data != nil {
                    
                    let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    print("Response String =>>>> \n \(responseString as Any)")
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? Dictionary<String, Any>
                        {
                            print("Valid Json Response =>>>> \n \(responseString as Any)")
                            completionHandler(json, nil)
                        }
                        else
                        {
                            let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                            print("Invalid Json Response =>>>> \n \(String(describing: jsonStr))")
                            completionHandler(nil, err)
                        }
                    }
                    catch let parseError {
                        let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                        print("Error could not parse JSON =>>> \n \(String(describing: jsonStr))")
                        print("Exception is =>>> /n '\(parseError)'")
                        
                        
                        completionHandler(nil, err)
                    }
                } else {
                    completionHandler(nil, err)
                }
                
                } as! (Data?, URLResponse?, Error?) -> Void).resume();
        }
    }
    
    
    
    func callJsonWebServiceWithUrl(_ apiPath:String,
                                   time : TimeInterval,
                                   methodName:String ,
                                   headers:Dictionary<String,String>?,
                                   params:Dictionary<String, AnyObject>?,
                                   onViewC : UIViewController?,
                                   completionHandler:@escaping (_ response: Dictionary<String, Any>?,_ error: Error?) -> Void) {
        
        
        //URL Session Object Creation
        let session = URLSession.shared
        
        
        // Creating final URL path
        print("API Path =>>>> \n \(apiPath as Any)")
        
        
        // Creating a URL from the API path
        let url:URL = URL(string: apiPath)!
        
        // Checking if there are parameters pass or not
        if params != nil {
            print("\n Params =>>>> \n \(params as Any)")
        } else {
            print("\n Params =>>>> \n \("No params sent")")
        }
        
       
        
        
        // Creating a UrlRequest using URL
        var request:URLRequest = URLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: time)
        
        
        // Assigning the HTTP method for the request
        request.httpMethod = methodName
        
        // Adding the headers in the request
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        
        // If user has explicitly passed some headers then assigining those headers too
        if headers != nil {
            request.allHTTPHeaderFields = headers
        }
        
        
        if let unwarp = params{
            request.httpBody = try! JSONSerialization.data(withJSONObject: unwarp, options: .prettyPrinted)
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: unwarp, options: JSONSerialization.WritingOptions.init(rawValue: 2))
                
                let bodyString = NSString(data: request.httpBody!, encoding: String.Encoding.utf8.rawValue)
                
                print("Body Params =>>> \n \(bodyString as Any)")
            } catch let exception {
                // Error Handling
                print("NSJSONSerialization Error =>>> \n \(exception as Any)")
                return
            }
            
        }
        
        if (iOSApiConnection.sharedInstance.isInternetConnected())
        {
            
            session.dataTask(with: request, completionHandler: { (data : Data?, response : URLResponse?, error: Error?) in
                
                
                if data != nil {
                    
                    let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? Dictionary<String, Any>
                        {
                            print("\nResponse String =>>>> \n\n \(responseString!)")
                            completionHandler(json, nil)
                        }
                        else
                        {
                            let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                            print("Invalid Json Response =>>>> \n \(String(describing: jsonStr))")
                            completionHandler(nil, error! as NSError)
                        }
                    }
                    catch let parseError {
                        let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                        print("Error could not parse JSON =>>> \n '\(String(describing: jsonStr))'")
                        print("Exception is =>>> /n '\(parseError)'")
                        
                        
                        completionHandler(nil, error)
                    }
                } else {
                    completionHandler(nil, error as NSError?)
                }
                
            }).resume()
        }
    }

    
}



















