//
//  DataAccessManager.swift
//  SwiftyDataAccessManager
//
//  Created by Sugam Kalra on 11/12/15.
//  Copyright © 2015 Sugam Kalra. All rights reserved.
//

import Foundation

class DataAccessManager {
    /// the singleton
    static let sharedInstance = DataAccessManager()
    // This prevents others from using the default '()' initializer for this class.
    private init() {}
    
    /**
     Fetch JSON resource
     
     - Parameters:
     - name: resource name
     - completionHandler: completion handler
     */
    func fetchJSONResourceWithName(name: String, completionHandler handler: (JSON?, ErrorType?) -> Void) {
        let resourceUrl = NSBundle.mainBundle().URLForResource(name, withExtension: "json")
        if resourceUrl == nil {
            fatalError("Could not find resource \(name)")
        }
        
        // create data from the resource content
        var data: NSData
        do {
            data = try NSData(contentsOfURL: resourceUrl!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
        } catch let error {
            handler(nil, error)
            return
        }
        
        // reading the json
        let json = JSON(data: data, options: NSJSONReadingOptions.AllowFragments, error: nil)
        if (json["delayResults"].double != nil) {
            let delay = json["delayResults"].double!
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                handler(json, nil)
            }
        }
        else {
            handler(json, nil)
        }
    }
    
    func fetchHelpsWithCompletionHandler(handler: ([Help], ErrorType?) -> Void) {
        self.fetchJSONResourceWithName("helps") { json, error in
            if error != nil {
                handler([], error)
                return
            }
        
            let data = json!["data"].array!
            var helps = [Help]()
            for helpJSON in data {
                let help = Help.helpFromJSON(helpJSON)
                helps.append(help)
            }
            dispatch_async(dispatch_get_main_queue()) {
                handler(helps, nil)
            }
        }
    }
    
    func fetchHelps() -> [Help] {
        var retHelps = [Help]()
        self.fetchJSONResourceWithName("helps") { json, error in
            let data = json!["data"].array!
            var helps = [Help]()
            for helpJSON in data {
                let help = Help.helpFromJSON(helpJSON)
                helps.append(help)
            }
            retHelps = helps
        }
        return retHelps
    }
    
}