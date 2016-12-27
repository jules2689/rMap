//
//  Secrets.swift
//  maps
//
//  Created by Julian Nadeau on 2016-12-26.
//  Copyright © 2016 Julian Nadeau. All rights reserved.
//

import Foundation

class Secrets {
    enum SecretsError: Error {
        case NotFound
    }
    
    class func secrets() -> Dictionary<String, Any?> {
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) as? Dictionary<String, AnyObject> {
                return dict
            }
        }
        print("No Secrets file found")
        return Dictionary<String, Any?>()
    }
}
