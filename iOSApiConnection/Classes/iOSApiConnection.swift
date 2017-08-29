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


public class iOSApiConnection: NSObject {
    
    // Singleton Object Creation
    public static let sharedInstance : iOSApiConnection = {
        let instance = iOSApiConnection()
        return instance
    }()
    
    // Checking the internet Internet Connection
    public func isInternetConnected() -> Bool {
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
   public  func callStringWebServiceWithUrl(_ apiPath:String,
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
    
    
    
    public func callJsonWebServiceWithUrl(_ apiPath:String,
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
    
    
    
    public func callUploadImageAtUrl(_ apiPath:String,
                                     time : TimeInterval,
                                     headers:Dictionary<String,String>?,
                                     uploadedKeyName: String,
                                     withArrayOfImages:[UIImage],
                                     withParams:Dictionary<String, AnyObject>?,
                                     completionHandler : @escaping (NSDictionary?, NSError?, Double, Bool) -> Void){
        
        
        var request : URLRequest = AFHTTPRequestSerializer().multipartFormRequest(withMethod: "POST", urlString: apiPath, parameters: withParams, constructingBodyWith: { (formdata: AFMultipartFormData) in
            
            if withArrayOfImages.count > 0  {
                for i in 1...withArrayOfImages.count {
                    let image = withArrayOfImages [i-1] as UIImage
                    let imageData = UIImageJPEGRepresentation(image, 0.6)
                    
                    // Creating time Interval here to give the unique name to each uploaded image
                    let time : TimeInterval = NSDate().timeIntervalSince1970
                    let nameOfImage = NSString(format: "%d_%d_image.jpg",i, time)
                    
                    formdata.appendPart(withFileData: imageData!, name: uploadedKeyName, fileName: nameOfImage as String, mimeType: "image/jpg/png/jpeg")
                }
            }
            
        }, error: nil) as URLRequest
        
        
        if let unwarp = withParams {
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
        
        
        // Adding the header parts
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("keep-alive", forHTTPHeaderField: "Connection")
        
        if headers != nil {
            request.allHTTPHeaderFields = headers
        }
        
        
        let manager : AFURLSessionManager = AFURLSessionManager(sessionConfiguration: .default)
        manager.responseSerializer = AFHTTPResponseSerializer()
        
        let uploadTask : URLSessionUploadTask!
        
        uploadTask = manager.uploadTask(withStreamedRequest: request, progress: { (progresss : Progress) in
            
            print("Upload progress\(progresss.fractionCompleted) \n ")
            
            completionHandler(nil, nil,progresss.fractionCompleted,false)
            
        }, completionHandler: { (response: URLResponse, data : Any?, err : Error?) in
            
            if err != nil {
                print("\nResponse String =>>>> \n\n \(err.debugDescription)")
                completionHandler(nil,err! as NSError?,0,false)
                
            } else {
                
                
                print("Files uploaded succesfully")
                let strData = NSString(data: (data! as! NSData) as Data, encoding: String.Encoding.utf8.rawValue)
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: (data! as! NSData) as Data, options: []) as? NSDictionary
                    {
                        
                        
                        print("\nResponse String =>>>> \n\n \(strData!)")
                        print("\nResponse Json =>>>> \n\n \(json)")
                        
                        completionHandler(json, nil , 1 , true)
                    }
                    
                }
                catch let parseError {
                    let jsonStr = NSString(data: data! as! Data, encoding: String.Encoding.utf8.rawValue)
                    print("Error could not parse JSON =>>> \n '\(String(describing: jsonStr))'")
                    print("Exception is =>>> /n '\(parseError)'")
                    
                    let errorInfo = NSError(domain: "error", code: 100, userInfo: nil)
                    completionHandler(nil,errorInfo,1,true)
                }
                
                
                
            }
        })
        
        uploadTask.resume()
        
        
    }

    
    
    
}



















