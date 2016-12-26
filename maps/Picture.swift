//
//  Records.swift
//  maps
//
//  Created by Julian Nadeau on 2016-12-24.
//  Copyright © 2016 Julian Nadeau. All rights reserved.
//

import Foundation
import ObjectMapper

class Picture: Mappable {
    var url: String!
    var type: String!
    var id: String!

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        url <- map["url"]
        type <- map["type"]
        id <- map["id"]
    }
}
