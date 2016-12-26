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
    func restaurantsDidFetch(sender: RestaurantsApi)
    func restaurantsDidError(sender: RestaurantsApi, errorMessage: String)
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
            self.fetchRestaurants(offset: nil)
        }
    }

    private func fetchRestaurants(offset: String?) {
        let airtableAppID = "appIMhRSxIBeDVPiv";
        let airtableAPIKey = "keynKoJjs79VHTt5c";

        // Prepare the URL request.
        var url = "https://api.airtable.com/v0/\(airtableAppID)/Restaurants?sort%5B0%5D%5Bfield%5D=Name&sort%5B0%5D%5Bdirection%5D=asc"
        if offset != nil {
            url = url + "&offset=" + offset!
        }
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
                self.didError(message: (error as! NSError).localizedDescription)
                return
            }
            
            // Catch HTTP errors (anything other than "200 OK").
            let httpResponse: HTTPURLResponse = (response as? HTTPURLResponse)!
            if httpResponse.statusCode != 200 {
                self.didError(message: "HTTP Error" + String(httpResponse.statusCode))
                return
            }
            
            // Check to see that the response included data.
            guard let responseData = data else {
                self.didError(message: "No data was found in the response from the server")
                return
            }
            
            // Try to serialize the data to JSON.
            do {
                let jsonData = try JSONSerialization.jsonObject(with: responseData, options:[]) as? [String: Any]
                
                let restaurants = Mapper<Restaurant>().mapArray(JSONObject: jsonData?["records"])!
                self.restaurants.append(contentsOf: restaurants)
                self.cacheImages(restaurants: restaurants)
                
                if let offset = jsonData?["offset"] as? String {
                    self.fetchRestaurants(offset: offset)
                }
                
                for delegate in self.delegates {
                    delegate.restaurantsDidFetch(sender: self)
                }
            } catch {
                self.didError(message: "Could not convert the server response to useable data")
                return
            }
            
        })
        
        // Start / resume the data task.
        task.resume()
    }
    
    // MARK: Image Handling
    
    func imageForPicture(picture: Picture) -> UIImage? {
        if let image = imageCache.object(forKey: picture.id as AnyObject) as? UIImage {
            return image
        } else {
            let filepath = self.getDocumentsDirectory().appendingPathComponent(picture.id + ".png").relativePath
            let data = FileManager.default.contents(atPath: filepath)
            if data != nil {
                let image = UIImage(data: data!)
                self.imageCache.setObject(image!, forKey: picture.id as AnyObject)
                return image
            }
            return nil
        }
    }
    
    private func cacheImages(restaurants: Array<Restaurant>) {
        DispatchQueue.global(qos: .background).async {
            for restaurant in restaurants {
                for picture in restaurant.pictures! {
                    if let url = NSURL(string: picture.url) {
                        if let data = NSData(contentsOf: url as URL) {
                            if let image = UIImage(data: data as Data) {
                                self.imageCache.setObject(image, forKey: picture.id as AnyObject)
                                if let imageData = UIImagePNGRepresentation(image) {
                                    let filename = self.getDocumentsDirectory().appendingPathComponent(picture.id + ".png")
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
    
    private func didError(message: String) {
        print("Error: \(message)")
        for delegate in self.delegates {
            delegate.restaurantsDidError(sender: self, errorMessage: message)
        }
    }
    
}
