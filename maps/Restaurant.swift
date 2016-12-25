//
//  restaurant.swift
//  maps
//
//  Created by Julian Nadeau on 2016-12-24.
//  Copyright © 2016 Julian Nadeau. All rights reserved.
//

import Foundation
import ObjectMapper

class Restaurant: Mappable {
    var id: String!
    var name: String!
    var cuisine: Array<String>?
    var notes: String?
    var pictures: Array<Picture>?
    var diet: Array<String>?
    var cost: String?
    var address: String!
    var rating: Double?
    var yelpUrl: String?
    var latitude: Double?
    var longitude: Double?
    var createdAt: Date!

    var presentedOnMap:Bool = false
    
    required init?(map: Map) {
        self.pictures = Array<Picture>()
    }

    // Mappable
    func mapping(map: Map) {
        id             <- map["id"]
        name           <- map["fields.Name"]
        cuisine        <- map["fields.Cuisine"]
        notes          <- map["fields.Notes"]
        pictures       <- map["fields.Pictures"]
        diet           <- map["fields.Diet"]
        cost           <- map["fields.Cost"]
        address        <- map["fields.Address"]
        rating         <- map["fields.Rating from Yelp"]
        yelpUrl        <- map["fields.Yelp URL"]
        latitude       <- map["fields.Latitude"]
        longitude      <- map["fields.Longitude"]
        createdAt      <- (map["createdTime"], DateTransform())
    }
}
