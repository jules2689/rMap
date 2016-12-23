//
//  Restaurants.swift
//  maps
//
//  Created by Julian Nadeau on 2016-12-22.
//  Copyright © 2016 Julian Nadeau. All rights reserved.
//

import Foundation
import UIKit

protocol RestaurantsDelegate: class {
    func restaurantsDidFinishFetch(sender: Restaurants)
}

class Restaurants {
    var restaurants: NSMutableArray!
    var imageCache: NSCache<AnyObject, AnyObject>!
    var delegates: NSMutableArray
    
    static let sharedInstance : Restaurants = {
        let instance = Restaurants()
        return instance
    }()
    
    init() {
        self.restaurants = NSMutableArray.init()
        self.delegates = NSMutableArray.init()
        self.imageCache = NSCache.init()
        DispatchQueue.global(qos: .background).async {
            self.fetchRestaurants();
        }
    }
    
    func imageForRestaurant(name: String) -> UIImage? {
        return imageCache.object(forKey: name as AnyObject) as? UIImage
    }
    
    func cacheImages(restaurants: NSArray) {
        DispatchQueue.global(qos: .background).async {
            for restaurant in restaurants {
                if let restaurantDict = restaurant as? NSDictionary {
                    if let pictureArray = restaurantDict["Pictures"] as? NSArray {
                        if let pictureDictionary = pictureArray[0] as? NSDictionary {
                            if let url = NSURL(string: (pictureDictionary["url"] as! String)) {
                                if let data = NSData(contentsOf: url as URL) {
                                    let name = restaurantDict["Name"] as! String
                                    self.imageCache.setObject(UIImage(data: data as Data)!, forKey: name as AnyObject)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func fetchRestaurants() {
        let airtableAppID = "appIMhRSxIBeDVPiv";
        let airtableAPIKey = "";
        let restaurantEntries : NSMutableArray = [] ;

        // Prepare the URL request.
        let url = "https://api.airtable.com/v0/\(airtableAppID)/Restaurants?sort%5B0%5D%5Bfield%5D=Name&sort%5B0%5D%5Bdirection%5D=asc"
        let urlRequest = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        
        // Specify the Authorization header.
        urlRequest.addValue("Bearer \(airtableAPIKey)", forHTTPHeaderField: "Authorization")
        
        // Prepare an NSURLSession to send the data request.
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // Create the data task, along with a completion handler.
        let task : URLSessionDataTask = session.dataTask(with: urlRequest as URLRequest, completionHandler: {(data, response, error) in
            
            // Catch general errors (such as unsupported URLs).
            guard error == nil else {
                print("Error")
                print(error!)
                return
            }
            
            // Catch HTTP errors (anything other than "200 OK").
            let httpResponse: HTTPURLResponse = (response as? HTTPURLResponse)!
            if httpResponse.statusCode != 200 {
                print("HTTP Error")
                print(httpResponse.statusCode)
                return
            }
            
            // Check to see that the response included data.
            guard let responseData = data else {
                print("Error: No data was found in the response.")
                return
            }
            
            // Try to serialize the data to JSON.
            do {
                
                let jsonData = try JSONSerialization.jsonObject(with: responseData, options:[]) as! NSDictionary
                
                for record in jsonData["records"] as! NSArray {
                    if let dict = record as? NSDictionary {
                        let restaurant = dict["fields"] as! NSDictionary
                        restaurantEntries.add(restaurant)
                    }
                }
                
                self.restaurants = restaurantEntries;
                self.cacheImages(restaurants: self.restaurants)
                for delegate in self.delegates {
                    (delegate as! RestaurantsDelegate).restaurantsDidFinishFetch(sender: self)
                }
                // Get the fields from the JSON data.
            } catch {
                print("Error: Unable to convert data to JSON.")
                return
            }
            
        })
        
        // Start / resume the data task.
        task.resume()
    }
    
}
