//
//  Restaurants.swift
//  maps
//
//  Created by Julian Nadeau on 2016-12-22.
//  Copyright © 2016 Julian Nadeau. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

protocol RestaurantsDelegate: class {
    func restaurantsDidFinishFetch(sender: RestaurantsApi)
}

class RestaurantsApi {
    var restaurants = Array<Restaurant>()
    var imageCache: NSCache<AnyObject, AnyObject>!
    var delegates = Array<RestaurantsDelegate>()
    
    static let sharedInstance : RestaurantsApi = {
        let instance = RestaurantsApi()
        return instance
    }()
    
    init() {
        self.imageCache = NSCache.init()
        DispatchQueue.global(qos: .background).async {
            self.fetchRestaurants();
        }
    }

    private func fetchRestaurants() {
        let airtableAppID = "appIMhRSxIBeDVPiv";
        let airtableAPIKey = "";

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
                let jsonData = try JSONSerialization.jsonObject(with: responseData, options:[]) as? [String: Array<Any>]
                self.restaurants = Mapper<Restaurant>().mapArray(JSONObject: jsonData?["records"])!
                self.cacheImages(restaurants: self.restaurants)
                for delegate in self.delegates {
                    delegate.restaurantsDidFinishFetch(sender: self)
                }
            } catch {
                print("Error: Unable to convert data to JSON.")
                return
            }
            
        })
        
        // Start / resume the data task.
        task.resume()
    }
    
    // MARK: Image Handling
    
    func imageForRestaurant(name: String) -> UIImage? {
        if let image = imageCache.object(forKey: name as AnyObject) as? UIImage {
            return image
        } else {
            let filepath = self.getDocumentsDirectory().appendingPathComponent(name + ".png").relativePath
            let data = FileManager.default.contents(atPath: filepath)
            if data != nil {
                let image = UIImage(data: data!)
                self.imageCache.setObject(image!, forKey: name as AnyObject)
                return image
            }
            return nil
        }
    }
    
    private func cacheImages(restaurants: Array<Restaurant>) {
        DispatchQueue.global(qos: .background).async {
            for restaurant in restaurants {
                if let picture = restaurant.pictures?[0] {
                    if let url = NSURL(string: picture.url) {
                        if let data = NSData(contentsOf: url as URL) {
                            if let image = UIImage(data: data as Data) {
                                self.imageCache.setObject(image, forKey: restaurant.name as AnyObject)
                                if let imageData = UIImagePNGRepresentation(image) {
                                    let filename = self.getDocumentsDirectory().appendingPathComponent(restaurant.name + ".png")
                                    try? imageData.write(to: filename)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
}
