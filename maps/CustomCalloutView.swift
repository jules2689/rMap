//
//  CustomCalloutView.swift
//  maps
//
//  Created by Julian Nadeau on 2016-12-22.
//  Copyright © 2016 Julian Nadeau. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CustomCalloutView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var notes: UITextView!
    
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var directionsButton: UIBarButtonItem!
    @IBOutlet weak var yelpButton: UIBarButtonItem!
    
    func setViewsWith(restaurant: NSDictionary, image: UIImage?) {
        self.titleLabel.text = (restaurant["Name"] as! String)
        self.addressLabel.text = (restaurant["Address"] as! String)
        if let cost = restaurant["Cost"] as? String {
           self.costLabel.text = cost
        }
        if let rating = restaurant["Rating from Yelp"] as? NSNumber {
            self.ratingLabel.text = rating.stringValue + "/5"
        }
        if let notes = restaurant["Notes"] as? String {
            self.notes.text = notes
        }
        if image != nil {
            self.imageView.image = image
            self.imageView.contentMode = UIViewContentMode.scaleAspectFill
        }
    }
}
