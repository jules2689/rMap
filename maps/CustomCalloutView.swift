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
        if var cost = restaurant["Cost"] as? String {
            let initialIndex = cost.characters.count
            let padding = 3 - cost.characters.count
            for _ in 1...padding { cost = cost + "$" }
            let blueColor = UIColor.init(colorLiteralRed: 21.0/255, green: 126.0/255, blue: 251.0/255, alpha: 1.0) as UIColor
            let attributedCost = NSMutableAttributedString(string: cost, attributes: [ NSForegroundColorAttributeName: blueColor ])
            attributedCost.addAttribute(NSForegroundColorAttributeName, value: UIColor.lightGray, range: NSRange.init(location: initialIndex, length: padding))
            
            self.costLabel.attributedText = attributedCost
        }
        if let rating = restaurant["Rating from Yelp"] as? NSNumber {
            self.ratingLabel.text = rating.stringValue
        }
        if let notes = restaurant["Notes"] as? String {
            self.notes.text = notes
            self.notes.sizeToFit()
        }
        if image != nil {
            self.imageView.image = image
            self.imageView.contentMode = UIViewContentMode.scaleAspectFill
        }
    }
}
