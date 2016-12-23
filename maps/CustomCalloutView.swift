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
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var notes: UITextView!
    @IBOutlet weak var closeButton: UIButton!
    
    func setViewsWithAnnotation(customAnnotation: CustomPointAnnotation) {
        self.titleLabel.text = (customAnnotation.restaurant["Name"] as! String)
        self.addressLabel.text = (customAnnotation.restaurant["Address"] as! String)
        self.notes.text = (customAnnotation.restaurant["Notes"] as! String)

        DispatchQueue.global(qos: .background).async {
            let pictureDictionary = ((customAnnotation.restaurant["Pictures"] as! NSArray)[0] as! NSDictionary)
            if let url = NSURL(string: (pictureDictionary["url"] as! String)) {
                if let data = NSData(contentsOf: url as URL) {
                    DispatchQueue.main.sync {
                        self.imageView.image = UIImage(data: data as Data)
                        self.imageView.contentMode = UIViewContentMode.scaleAspectFill
                    }
                }
            }
        }

    }
}
